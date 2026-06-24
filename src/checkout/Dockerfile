FROM node:22-alpine AS builder
WORKDIR /app
RUN corepack enable
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/releases ./.yarn/releases
RUN yarn install 
COPY . .
RUN yarn build

FROM node:22-alpine AS production
WORKDIR /app
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
ENV NODE_ENV=production
ENV PORT=8080
RUN corepack enable
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/releases ./.yarn/releases
RUN yarn workspaces focus --all --production
COPY --from=builder /app/dist ./dist
EXPOSE 8080
USER appuser 
CMD ["node", "dist/main.js"]
