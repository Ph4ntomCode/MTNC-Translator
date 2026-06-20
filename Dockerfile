# =============================================================================
# MTNC Translator - Docker Image
# =============================================================================
# Multi-stage build: compile TypeScript, then run in minimal Node.js image
#
# Build:   docker build -t mtnc-translator .
# Run:     docker run --rm -v $(pwd)/mods:/mods mtnc-translator translate /mods/Mod.dll
# Shell:   docker run --rm -it --entrypoint /bin/bash mtnc-translator
# =============================================================================

# ---- Stage 1: Build ----
FROM node:20-alpine AS builder

WORKDIR /app

# Install build dependencies (only what's needed for TypeScript compilation)
RUN apk add --no-cache git

# Copy dependency manifests
COPY package.json package-lock.json* ./

# Install all dependencies (including devDependencies for TypeScript build)
RUN npm ci

# Copy source code
COPY tsconfig.json ./
COPY src/ ./src/
COPY bin/ ./bin/
COPY prism_mod_api.hpp ./

# Build TypeScript
RUN npm run build

# ---- Stage 2: Runtime ----
FROM node:20-alpine AS runtime

WORKDIR /app

# Install runtime dependencies: CMake and C++ compiler for building translated code
RUN apk add --no-cache cmake g++ make

# Copy production dependencies
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev --ignore-scripts

# Copy built distribution
COPY --from=builder /app/dist/ ./dist/
COPY --from=builder /app/bin/ ./bin/
COPY --from=builder /app/prism_mod_api.hpp ./

# Copy shared config
COPY config/ ./config/
COPY mtnc-config.example.json ./

# Copy ILParser if available
COPY src/tools/ilparser/ ./src/tools/ilparser/

# Create volumes for user code
VOLUME [ "/mods", "/output" ]

# Set environment defaults
ENV NODE_ENV=production

# Entry point
ENTRYPOINT ["node", "dist/cli/index.js"]
CMD ["--help"]

# Metadata
LABEL org.opencontainers.image.title="MTNC Translator"
LABEL org.opencontainers.image.description="Universal C# to C++ IL2CPP translator for game modding"
LABEL org.opencontainers.image.licenses="MIT"
