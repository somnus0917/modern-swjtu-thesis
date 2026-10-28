"""Compile immutable Git snapshots without touching the user's worktree or cache."""
import io
import re
import subprocess
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT/'build'/'audit'
for revision, name in [('663889d', 'original'), ('67b7f75', 'before')]:
    target = OUT/name
    if not target.exists():
        data = subprocess.check_output(['git', 'archive', revision], cwd=ROOT)
        with tarfile.open(fileobj=io.BytesIO(data)) as archive:
            archive.extractall(target, filter='data')
    for entry in ['thesis.typ', 'thesis-master.typ']:
        path = target/'template'/entry
        if not path.exists():
            continue
        source = path.read_text(encoding='utf-8')
        source = re.sub(r'"@preview/modern-swjtu-thesis:[^"]+"', '"../lib.typ"', source)
        local = path.with_name(path.stem+'-local.typ')
        local.write_text(source, encoding='utf-8')
        result = subprocess.run(['typst', 'compile', '--root', str(target), str(local), str(OUT/f'{name}-{path.stem}.pdf')],
                                capture_output=True, encoding='utf-8')
        (OUT/f'{name}-{path.stem}.log').write_text(result.stdout+result.stderr, encoding='utf-8')
        print(name, entry, result.returncode)
        if result.returncode:
            print(result.stderr[-4000:])
