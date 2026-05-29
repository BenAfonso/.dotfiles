EMOJI=
# YESTERDAY=$(curl -s -X GET https://www.api-couleur-tempo.fr/api/jourTempo/yesterday | jq .libCouleur -r)
TODAY=$(curl -s -X GET https://www.api-couleur-tempo.fr/api/jourTempo/today | jq .libCouleur -r)
TOMORROW=$(curl -s -X GET https://www.api-couleur-tempo.fr/api/jourTempo/tomorrow | jq .libCouleur -r)
 
getColorEmoji () {
  case "$1" in 
    "Bleu") echo -n "🔵";;
    "Rouge") echo -n "🔴";;
    "Blanc") echo -n "⚪";;
    "*") echo -n "⚫";;
  esac
}

echo "$(getColorEmoji $TODAY)&gt;$(getColorEmoji $TOMORROW)"
