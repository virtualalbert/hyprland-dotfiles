#!/bin/bash
if eww active-windows | grep -q "control-center"; then
    eww close control-center
else
    eww open control-center
fi
