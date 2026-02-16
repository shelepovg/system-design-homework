# Переходим в каталог проекта likec4 (скрипт лежит в likec4/scripts/)
cd "$(dirname "$0")/.."

# Build
# likec4 build -o ../dist

# start server
# sudo likec4 start

# Export puml — только схемы этого проекта (каталог с .likec4rc и *.c4)
likec4 gen plantuml -o ../doc/схемы
# Обход для превью PlantUML в (стандартный PlantUML не знает person из C4/LikeC4):
# 1) person -> rectangle (person не входит в стандарт, парсер падает на этой строке)
# 2) <<Notification>> -> <<Notify>> (конфликт с зарезервированным словом)
# 3) убираем "==" в начале подписей (Creole ломает парсер)
find ../doc/схемы -name '*.puml' -exec perl -i -pe 's/skinparam person<</skinparam rectangle<</g; s/\bperson "/rectangle "/g; s/<<Notification>>/<<Notify>>/g; s/"==/"/g' {} \;

# Генерация PNG из puml в doc/images (пути от корня репозитория)
ROOT_DIR="$(cd .. && pwd)"
SCHEMAS_DIR="$ROOT_DIR/doc/схемы"
IMAGES_DIR="$ROOT_DIR/doc/images"
mkdir -p "$IMAGES_DIR"
run_plantuml() {
  local out="$1"
  shift
  if command -v plantuml &>/dev/null; then
    plantuml -tpng -charset utf-8 -o "$out" "$@"
  elif [ -n "${PLANTUML_JAR}" ] && [ -f "${PLANTUML_JAR}" ]; then
    java -Djava.awt.headless=true -jar "${PLANTUML_JAR}" -tpng -charset utf-8 -o "$out" "$@"
  else
    local jar
    for base in "${HOME}/.vscode/extensions" "${HOME}/.cursor/extensions"; do
      [ -d "$base" ] && jar=$(find "$base" -maxdepth 3 -name "plantuml.jar" 2>/dev/null | head -1) && [ -n "$jar" ] && break
    done
    if [ -n "$jar" ] && command -v java &>/dev/null; then
      java -Djava.awt.headless=true -jar "$jar" -tpng -charset utf-8 -o "$out" "$@"
    else
      echo "Для PNG: brew install plantuml или задайте PLANTUML_JAR"
      return 1
    fi
  fi
}
for f in "$SCHEMAS_DIR"/*.puml; do
  [ -f "$f" ] && run_plantuml "$IMAGES_DIR" "$f" && echo "PNG: $(basename "$f" .puml).png"
done
# Удаляем .cmapx (карты изображений) — нужны только при встраивании PNG в HTML с кликабельными областями
rm -f "$IMAGES_DIR"/*.cmapx
