#!/bin/bash

# Quick Start Backend
# Run this in Terminal 1

# Get the project root directory (parent of scripts folder)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT/backend"

echo "🔴 Starting Backend (NestJS)..."
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Copying from .env.example..."
    cp .env.example .env
    echo "✅ Please edit backend/.env with your database credentials"
    exit 1
fi

echo "🧬 Generating Prisma Client..."
npm run prisma:generate

echo "🗄️  Applying database migrations..."
npm run prisma:deploy

echo "🌱 Seeding default users (safe)..."
npm run prisma:seed

echo "🚀 Starting development server..."
echo "Backend will run at: http://localhost:4000"
echo ""

npm run start:dev
