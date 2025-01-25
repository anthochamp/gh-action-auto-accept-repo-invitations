FROM alpine:3.21.2

# hadolint ignore=DL3018
RUN apk --no-cache add jq curl

COPY --chmod=775 action.sh /

CMD ["/action.sh"]
