FROM alpine:latest

RUN apk add jq curl

COPY --chmod=775 action.sh /

CMD ["/action.sh"]
