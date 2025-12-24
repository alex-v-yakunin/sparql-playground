#!/bin/bash
#
# SPARQL Playground - Запуск одной командой
#
# Этот скрипт запускает SPARQL playground:
# - Запускает GraphDB в Docker
# - Создаёт repository
# - Загружает ADR датасет
# - Проверяет установку
#
# Использование: ./start.sh
#

./scripts/setup.sh
