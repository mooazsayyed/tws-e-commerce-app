# Stage 1: Build Stage
FROM node:18-alpine AS builder

WORKDIR /app

# Install deps needed to build native modules
RUN apk add --no-cache python3 make g++

# Copy only package files first (for better caching)
COPY package*.json ./

# Install deps (use --frozen-lockfile for Yarn or ci for npm)
RUN npm ci --omit=dev

# Copy rest of the code
COPY . .

# Disable telemetry to save time
ENV NEXT_TELEMETRY_DISABLED=1

# Build Next.js
RUN npm run build

# Stage 2: Production Stage
FROM node:18-alpine AS runner
WORKDIR /app

# Copy only needed output
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

CMD ["node", "server.js"]
