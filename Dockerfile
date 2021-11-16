FROM node:14-slim as build

WORKDIR /home/pptruser
COPY package*.json ./
# The seccomp profile is not needed within the container but
# we included it for convenience, so that it can be copied to the host from a temporary container.
COPY chromium_seccomp.json ./

RUN  apt-get update \
     # Install latest chrome dev package, which installs the necessary libs to
     # make the bundled version of Chromium that Puppeteer installs work.
     # python3, make and build-essential are not necessary and can be removed again after npm install has sucessfully run
     && apt-get install -y wget gnupg2 ca-certificates python3 make build-essential libxtst6 libxss1 --no-install-recommends \
     && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
     && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
     && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
     && apt-get update \
     && apt-get install -y google-chrome-unstable --no-install-recommends \
     && rm -rf /var/lib/apt/lists/* \
     && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
     && mkdir -p /home/pptruser/Downloads \
     && chown -R pptruser:pptruser /home/pptruser \
     && npm install \
     && apt-get remove -y python3 build-essential make gnupg2 \
     && apt-get autoremove -y \
     && apt-get remove -y google-chrome-unstable

FROM build as production

COPY ./src .

RUN chown -R pptruser:pptruser ./

USER pptruser
EXPOSE 9000

CMD ["index.js"]