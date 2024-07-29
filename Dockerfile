FROM python:3.10.11-alpine3.16
LABEL maintainer="https://github.com/flytutu-susu/Cloudflare-DDNS"
LABEL description="Cloudflare-DDNS"

ENV TZ Asia/Shanghai

COPY ddns.py /home/Cloudflare-DDNS.back/ddns.py
COPY lib/ /home/Cloudflare-DDNS.back/lib/
COPY docker/ddns-docker /home/Cloudflare-DDNS.back/ddns-docker
COPY conf/ /home/Cloudflare-DDNS.back/conf/
COPY docker/start.sh /start.sh

RUN python -m pip install -i https://mirrors.aliyun.com/pypi/simple/ httpx==0.25.0 \
    && chmod 777 /start.sh

CMD ["/start.sh"]
