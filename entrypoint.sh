#! sh

CONFIG_FILE="/curvytron/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
	cp "$CONFIG_FILE.sample" $CONFIG_FILE
	sed -i "s/\"port\": 8080/\"port\": ${CURVYTRON__PORT:-8080}/" $CONFIG_FILE
fi

npm run serve
