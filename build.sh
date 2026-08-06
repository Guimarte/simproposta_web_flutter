#!/bin/bash
echo "🚀 Baixando e configurando o SDK do Flutter na Vercel..."

# Instala o Flutter SDK stable se não existir no cache da Vercel
if [ -d "flutter" ]; then
    cd flutter
    git pull
    cd ..
else
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Adiciona o Flutter ao PATH de execução
export PATH="$PATH:`pwd`/flutter/bin"

echo "⚙️ Habilitando suporte a Flutter Web e instalando dependências..."
flutter config --enable-web
flutter pub get

echo "📦 Compilando Flutter Web em modo Release com base-href=/ ..."
flutter build web --release --base-href=/
