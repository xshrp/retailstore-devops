#!/bin/bash
cd "$(dirname "$0")"
zip -j lambda_notifier.zip index.js
echo "✅ lambda_notifier.zip generado"