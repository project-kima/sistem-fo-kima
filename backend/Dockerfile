FROM node:22-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci

# Copy prisma schema and generate client
COPY prisma ./prisma
COPY prisma.config.ts ./
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
RUN npx prisma generate

# Copy source code and build
COPY . .
RUN npm run build

# Production stage
FROM node:22-alpine

WORKDIR /app

# Install production dependencies
COPY package*.json ./
RUN npm ci --omit=dev

# Generate prisma client for production
COPY prisma ./prisma
COPY prisma.config.ts ./
ENV DATABASE_URL="postgresql://dummy:dummy@localhost:5432/dummy"
RUN npx prisma generate

# Copy built assets
COPY --from=builder /app/dist ./dist

# Set env and expose port
ENV NODE_ENV=production
ENV PORT=4000
EXPOSE 4000

# Start the application
CMD ["npm", "run", "start:prod"]
