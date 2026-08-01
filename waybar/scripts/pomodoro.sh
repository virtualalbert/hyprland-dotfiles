#!/usr/bin/env bash

STATE_DIR="$HOME/.cache/pomodoro"
STATE_FILE="$STATE_DIR/state"
mkdir -p "$STATE_DIR"

load() {
    STATUS="idle"
    END=0
    REMAINING=0
    LABEL="TIMER"
    NOTIFIED=0
    [[ -f "$STATE_FILE" ]] && source "$STATE_FILE"
}

save() {
cat > "$STATE_FILE" <<EOF
STATUS=$STATUS
END=$END
REMAINING=$REMAINING
LABEL="$LABEL"
NOTIFIED=$NOTIFIED
EOF
}

fmt() {
    local s=$1
    (( s < 0 )) && s=0

    if (( s >= 3600 )); then
        printf "%d:%02d:%02d" $((s/3600)) $(((s%3600)/60)) $((s%60))
    else
        printf "%02d:%02d" $((s/60)) $((s%60))
    fi
}

notify() {
    command -v notify-send >/dev/null &&
        notify-send -a pomodoro "$1" "$2"
}

cmd_start() {
    local mins=${1:-25}
    local label=${2:-WORK}

    STATUS="running"
    END=$(( $(date +%s) + mins*60 ))
    REMAINING=0
    LABEL="$label"
    NOTIFIED=0
    save
}

cmd_pause() {
    load
    [[ "$STATUS" != running ]] && exit 0

    REMAINING=$(( END-$(date +%s) ))
    (( REMAINING < 0 )) && REMAINING=0

    STATUS="paused"
    save
}

cmd_resume() {
    load
    [[ "$STATUS" != paused ]] && exit 0

    STATUS="running"
    END=$(( $(date +%s) + REMAINING ))
    save
}

cmd_toggle() {
    load

    case "$STATUS" in
        running) cmd_pause ;;
        paused) cmd_resume ;;
        idle) cmd_start 25 WORK ;;
    esac
}

cmd_stop() {
    STATUS="idle"
    END=0
    REMAINING=0
    LABEL="TIMER"
    NOTIFIED=0
    save
}

cmd_add() {
    load
    local mins=${1:-5}

    if [[ "$STATUS" == running ]]; then
        END=$(( END + mins*60 ))
    else
        REMAINING=$(( REMAINING + mins*60 ))
    fi

    save
}

cmd_status() {
    load
    local left

    case "$STATUS" in
        running)
            left=$(( END-$(date +%s) ))

            if (( left <= 0 )); then
                left=0

                if [[ "$NOTIFIED" == 0 ]]; then
                    notify "Pomodoro" "$LABEL finished!"
                    NOTIFIED=1
                    STATUS="idle"
                    save
                fi
            fi
            ;;

        paused)
            left=$REMAINING
            ;;

        *)
            echo '{"text":"--:--","class":"idle","tooltip":"Pomodoro"}'
            exit 0
            ;;
    esac

    printf '{"text":"%s %s","class":"%s","tooltip":"%s"}\n' \
        "$(fmt "$left")" \
        "$LABEL" \
        "$STATUS" \
        "$LABEL"
}

case "$1" in
    start)
        cmd_start "$2" "$3"
        ;;
    pause)
        cmd_pause
        ;;
    resume)
        cmd_resume
        ;;
    toggle)
        cmd_toggle
        ;;
    stop)
        cmd_stop
        ;;
    add)
        cmd_add "$2"
        ;;
    status)
        cmd_status
        ;;
    *)
        echo "Usage: $0 {start|pause|resume|toggle|stop|add|status}"
        ;;
esac
