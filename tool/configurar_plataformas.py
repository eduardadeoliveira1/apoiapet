#!/usr/bin/env python3
"""Ajusta AndroidManifest.xml e Info.plist depois de `flutter create .`.

Adiciona: permissões de internet/localização (Android), textos de uso de
localização/câmera/galeria (iOS) e o nome "ApoiaPet" do aplicativo.
Pode ser executado mais de uma vez (é idempotente).
"""
import pathlib
import re
import sys

raiz = pathlib.Path(__file__).resolve().parent.parent
ok = False

manifest = raiz / "android/app/src/main/AndroidManifest.xml"
if manifest.exists():
    t = manifest.read_text(encoding="utf-8")
    perms = [
        "android.permission.INTERNET",
        "android.permission.ACCESS_COARSE_LOCATION",
        "android.permission.ACCESS_FINE_LOCATION",
    ]
    novas = "".join(
        f'    <uses-permission android:name="{p}"/>\n'
        for p in perms
        if p not in t
    )
    if novas:
        t = re.sub(r"(<manifest[^>]*>\n)", lambda m: m.group(1) + novas, t, count=1)
    t = re.sub(r'android:label="[^"]*"', 'android:label="ApoiaPet"', t, count=1)
    manifest.write_text(t, encoding="utf-8")
    print("Android: permissões e nome ajustados.")
    ok = True

plist = raiz / "ios/Runner/Info.plist"
if plist.exists():
    t = plist.read_text(encoding="utf-8")
    chaves = {
        "NSLocationWhenInUseUsageDescription":
            "O ApoiaPet usa sua localização para centralizar o mapa e marcar novos pontos.",
        "NSCameraUsageDescription":
            "O ApoiaPet usa a câmera para fotografar o ponto de apoio.",
        "NSPhotoLibraryUsageDescription":
            "O ApoiaPet acessa suas fotos para anexar a imagem do ponto de apoio.",
    }
    for k, v in chaves.items():
        if k not in t:
            t = t.replace("</dict>\n</plist>",
                          f"\t<key>{k}</key>\n\t<string>{v}</string>\n</dict>\n</plist>")
    t = re.sub(r"(<key>CFBundleDisplayName</key>\s*<string>)[^<]*", r"\1ApoiaPet", t)
    plist.write_text(t, encoding="utf-8")
    print("iOS: textos de permissão ajustados.")
    ok = True

if not ok:
    sys.exit("Rode `flutter create .` antes (não encontrei android/ nem ios/).")
