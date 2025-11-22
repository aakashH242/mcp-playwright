# Build and runtime image for MCP Playwright Server
# Uses the Playwright base image which already has browser binaries and deps.

FROM mcr.microsoft.com/playwright:v1.56.1-noble AS base
WORKDIR /app

# Install dependencies and build
COPY package*.json ./
COPY tsconfig*.json ./
COPY src ./src
RUN npm ci --omit=dev && npm run build

# Runtime stage
FROM mcr.microsoft.com/playwright:v1.56.1-noble
WORKDIR /app
ENV PLAYWRIGHT_HEADLESS=1

# Create data directory for streamed resources
RUN mkdir -p /data

COPY --from=base /app/package*.json ./
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/dist ./dist

# Expose HTTP port for streamable mode
EXPOSE 8000

CMD ["node", "dist/index.js"]
