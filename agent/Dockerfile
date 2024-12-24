ARG editorImage="trieudinhquang2002/unity-editor"

FROM $editorImage

WORKDIR /

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
