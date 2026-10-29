#!/usr/bin/env python3
"""Exporte / importe les enregistrements qui sont en fait de la configuration.

Usage:
  python3 -I scripts/data/sfdata.py export --org "SPA Prod" [--dataset NomObjet]
  python3 -I scripts/data/sfdata.py import --org "SPA DEV2" [--dataset NomObjet] [--apply]

`import` simule par defaut ; il n'ecrit dans l'org qu'avec --apply.
Les datasets sont declares dans data/datasets.json, les fichiers sont dans data/records/<Objet>/.
"""
import argparse, json, os, re, subprocess, sys, tempfile, unicodedata

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DATA = os.path.join(ROOT, "data")
API = "v62.0"


def sf(*args, stdin=None):
    p = subprocess.run(["sf", *args], capture_output=True, text=True, input=stdin)
    try:
        out = json.loads(p.stdout)
    except ValueError:
        sys.exit(f"sf {' '.join(args)}\n{p.stdout}{p.stderr}")
    if out.get("status") != 0:
        sys.exit(f"sf {' '.join(args)}\n{out.get('message')}")
    return out.get("result")


def datasets():
    return json.load(open(os.path.join(DATA, "datasets.json")))


def writable_fields(obj, conf, org):
    desc = sf("sobject", "describe", "-s", obj, "-o", org, "--json")
    skip = set(conf.get("exclude", [])) | {"Id"}
    return sorted(
        f["name"] for f in desc["fields"]
        if f["createable"] and not f["calculated"] and f["type"] not in ("encryptedstring", "reference")
        and f["name"] not in skip
    )


def fetch(obj, conf, org):
    fields = writable_fields(obj, conf, org)
    if conf["key"] not in fields:
        fields.append(conf["key"])
    q = f"SELECT {','.join(fields)} FROM {obj} ORDER BY {conf['key']}"
    recs = sf("data", "query", "-q", q, "-o", org, "--json")["records"]
    return [{k: v for k, v in r.items() if k != "attributes" and v is not None} for r in recs]


def slug(s):
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode()
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", s).strip("_") or "record"


def folder(obj):
    return os.path.join(DATA, "records", obj)


def cmd_export(a):
    for obj, conf in datasets().items():
        if a.dataset and a.dataset != obj:
            continue
        os.makedirs(folder(obj), exist_ok=True)
        recs, seen = fetch(obj, conf, a.org), set()
        for r in recs:
            name = slug(r[conf["key"]])
            if name in seen:
                sys.exit(f"{obj}: deux enregistrements donnent le meme nom de fichier ({name})")
            seen.add(name)
            with open(os.path.join(folder(obj), name + ".json"), "w", encoding="utf-8") as f:
                json.dump(r, f, ensure_ascii=False, indent=2, sort_keys=True); f.write("\n")
            if "html" in conf:
                body = "".join(r.get(x, "") for x in conf["html"]["fields"])
                with open(os.path.join(folder(obj), name + ".html"), "w", encoding="utf-8") as f:
                    f.write(body)
        for fn in os.listdir(folder(obj)):  # supprime ce qui n'existe plus dans l'org
            if os.path.splitext(fn)[0] not in seen and fn.endswith((".json", ".html")):
                os.remove(os.path.join(folder(obj), fn))
        print(f"{obj}: {len(recs)} enregistrement(s) exporte(s)")


def cmd_import(a):
    for obj, conf in datasets().items():
        if a.dataset and a.dataset != obj:
            continue
        key = conf["key"]
        wanted = [json.load(open(os.path.join(folder(obj), fn), encoding="utf-8"))
                  for fn in sorted(os.listdir(folder(obj))) if fn.endswith(".json")]
        in_org = {r[key]: r for r in fetch(obj, conf, a.org)}
        id_of = {r[key]: r["Id"] for r in sf("data", "query", "-q", f"SELECT Id,{key} FROM {obj}", "-o", a.org, "--json")["records"]}
        for rec in wanted:
            cur = in_org.get(rec[key])
            if cur is None:
                action = "CREATE"
            else:
                changed = sorted(k for k in rec if rec[k] != cur.get(k))
                action = f"UPDATE ({', '.join(changed)})" if changed else "inchange"
            print(f"{obj}: {rec[key]}: {action}")
            if not a.apply or action == "inchange":
                continue
            body = {k: v for k, v in rec.items()}
            if cur is not None:
                url, method = f"/services/data/{API}/sobjects/{obj}/{id_of[rec[key]]}", "PATCH"
            else:
                url, method = f"/services/data/{API}/sobjects/{obj}", "POST"
            with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False, encoding="utf-8") as t:
                json.dump(body, t, ensure_ascii=False)
            try:
                p = subprocess.run(["sf", "api", "request", "rest", url, "-X", method, "-b", t.name, "-o", a.org],
                                   capture_output=True, text=True)
                if p.returncode != 0:
                    sys.exit(f"echec {method} {obj} {rec[key]}:\n{p.stdout}{p.stderr}")
            finally:
                os.unlink(t.name)
    if not a.apply:
        print("\nSimulation uniquement : relancer avec --apply pour ecrire dans l'org.")


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    for name, fn in (("export", cmd_export), ("import", cmd_import)):
        s = sub.add_parser(name)
        s.add_argument("--org", required=True, help="alias ou username (obligatoire, pas d'org par defaut)")
        s.add_argument("--dataset")
        if name == "import":
            s.add_argument("--apply", action="store_true")
        s.set_defaults(fn=fn)
    a = p.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
