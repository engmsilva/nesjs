###################
# Builder
###################

FROM node:16.17.0-alpine As builder

ARG BUILD_ID
LABEL stage=builder
LABEL build=$BUILD_ID

RUN echo $BUILD_ID
WORKDIR /usr/src/app

COPY package*.json ./

RUN npm config set registry http://registry.npmjs.org/

RUN npm install glob rimraf

RUN npm install

COPY . .

RUN npm run build

RUN echo $(ls -1 /usr/src/app/dist)

FROM node:16.17.0-alpine As hml

RUN apk update
RUN apk add busybox-extras
RUN apk add curl

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

USER appuser

WORKDIR /home/appuser

COPY --from=builder /usr/src/app/node_modules ./node_modules

COPY --from=builder /usr/src/app/dist ./dist

RUN echo $(ls -1 -la /home/appuser)

CMD ["node", "dist/main"]