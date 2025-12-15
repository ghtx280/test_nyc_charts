#!/usr/bin/env bash

# ====== CONFIG ======
CHARTS_SERVICE_URL="${CHARTS_SERVICE_URL:-http://127.0.0.1:8000}"
CHARTS_SERVICE_TOKEN="abc"

URL_OVERRIDE="$1"                 # optional: custom url
HIRING_GROUP_ID="$2"              # required
HIRING_SUBGROUP_ID="$3"           # optional

URL="${URL_OVERRIDE:-$CHARTS_SERVICE_URL}"

# ====== PARAMS JSON ======
PARAMS=$(jq -n \
  --argjson hiring_group "$HIRING_GROUP_ID" \
  --argjson hiring_group_id "$HIRING_GROUP_ID" \
  --argjson hiring_subgroup_id "${HIRING_SUBGROUP_ID:-null}" \
  '{
    hiring_group: $hiring_group,
    hiring_group_id: $hiring_group_id,
    hiring_subgroup_id: $hiring_subgroup_id,
    access_flags_special: []
  }'
)

# ====== CHARTS ======
CHARTS=(
  nyc_2025_numbers
  nyc_2025_pie_hires_by_domain
  nyc_2025_bar_hires_by_year
  nyc_2025_bar_employees_engaged_by_role
  nyc_2025_pie_employees_engaged_by_domain
  nyc_2025_bar_employees_engaged_by_year
  nyc_2025_bar_ined_participants_by_year
  nyc_2025_pie_ined_by_project_type
  nyc_2025_bar_community
  nyc_2025_list_employees_new_engaged
)

# ====== LOOP ======
for CHART in "${CHARTS[@]}"; do
  echo "==> $CHART"

  RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$URL?out=json&chart=$CHART" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $CHARTS_SERVICE_TOKEN" \
    -d "$PARAMS"
  )

  BODY=$(echo "$RESPONSE" | sed '$d')
  STATUS=$(echo "$RESPONSE" | tail -n1)

  if [ "$STATUS" = "200" ]; then
    echo "ok"
  else
    echo "$BODY"
  fi
done

