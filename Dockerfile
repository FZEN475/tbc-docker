FROM alpine:3.22

CMD ["sh", "-c", "while true; do sleep 1; done"]

HEALTHCHECK --interval=10s --timeout=2s --retries=3 \
  CMD sh -c "echo ok || exit 1"