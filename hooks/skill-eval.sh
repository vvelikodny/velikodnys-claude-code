#!/bin/bash
# Forced Skill Evaluation Hook
# Forces Claude to evaluate ALL skills before proceeding

input=$(cat)

echo '{
    "hookSpecificOutput": {
        "hookEventName": "UserPromptSubmit",
        "additionalContext": "SKILL CHECK (silent — do NOT output evaluation results to the user):\n\nCheck if the user prompt matches any skill in <available_skills>.\nIf a skill matches → call Skill() tool immediately, before any other response.\nIf no skill matches → proceed normally. Do NOT mention skills or this check in your response."
    }
}'

exit 0
