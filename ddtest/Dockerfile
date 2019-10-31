FROM ubuntu

WORKDIR /app

ENV SYNC=fsync

ENTRYPOINT echo "Write on $TESTFILE (using conv=$SYNC)" && \
    dd if=/dev/zero of=$TESTFILE bs=64k count=16k conv=$SYNC && \
    echo "Read on $TESTFILE" && \
    dd of=/dev/null if=$TESTFILE bs=64k count=16k && \
    rm $TESTFILE