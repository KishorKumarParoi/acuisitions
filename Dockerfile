# Build stage
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with security audit
RUN npm ci --only=production \
    && npm audit --production --audit-level=moderate \
    && npm cache clean --force

# Copy source code
COPY . .

# Optional: Run build if needed (TypeScript, etc.)
# RUN npm run build

# Runtime stage
FROM node:22-alpine

WORKDIR /app

# Install essential utilities (dumb-init, curl for health checks)
RUN apk add --no-cache \
    dumb-init \
    curl \
    && rm -rf /var/cache/apk/*

# Create non-root user with proper shell
RUN addgroup -g 1001 -S nodejs \
    && adduser -S nodejs -u 1001 -h /home/nodejs -s /sbin/nologin

# Copy from builder with proper ownership
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
COPY --chown=nodejs:nodejs . .

# Create logs and tmp directories with proper permissions
RUN mkdir -p logs tmp .node-gyp \
    && chown -R nodejs:nodejs logs tmp .node-gyp \
    && chmod 755 logs tmp

# Set environment variables
ENV NODE_ENV=production \
    NODE_OPTIONS="--max-old-space-size=512" \
    PORT=3001

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3001

# Health check with curl (more reliable)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3001/health || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "--enable-source-maps", "src/index.js"]
