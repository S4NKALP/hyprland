#!/bin/bash


    PREV_STATUS="Unknown" # Initialize previous status
    FULL_CHARGE_NOTIFIED=0
    LOW_BATTERY_NOTIFIED=0

    while true; do
        STATUS=$(cat /sys/class/power_supply/AC/online 2>/dev/null)   # Get charger status using power supply directory

        if [ "$STATUS" != "$PREV_STATUS" ]; then   # Check if the charger status has changed
            FULL_CHARGE_NOTIFIED=0     # Reset full charge notification state when charger status changes
            LOW_BATTERY_NOTIFIED=0     # Reset low battery notification state when charger status changes
            PREV_STATUS="$STATUS"   # Update previous status
        fi

        # Get battery percentage and remaining time using acpi
        BATTERY_INFO=$(acpi)
        PERCENT=$(echo "$BATTERY_INFO" | awk -F ',|%' '{print $2}')

        if [ "$STATUS" == "1" ] && [ "$PERCENT" -eq 100 ] && [ "$FULL_CHARGE_NOTIFIED" -eq 0 ]; then      # Check if the battery is charging and the percentage is 100%
            notify-send -u low "🔌 Battery Fully Charged" "You can unplug the charger"        # Send a notification when the battery is fully charged
            FULL_CHARGE_NOTIFIED=1    # Set the state to indicate that the full charge notification has been sent
        fi

        if [ "$PERCENT" -le 40 ] && [ "$LOW_BATTERY_NOTIFIED" -eq 0 ]; then     # Check if the battery percentage is less than or equal to 20% and low battery notification has not been sent
            notify-send -u critical "🪫 Low Battery" "Plug in the charger"    # Send low battery notification
            LOW_BATTERY_NOTIFIED=1  # Set the state to indicate that the low battery notification has been sent
        fi
        sleep 0.1  # Sleep for some time before checking again
    done
