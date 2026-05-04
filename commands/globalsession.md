---
description: Show ALL sessions across ALL directories
---
!`sqlite3 ~/.local/share/opencode/opencode.db "SELECT id, title, substr(directory,1,40) as dir, datetime(time_updated/1000, 'unixepoch') as updated FROM session ORDER BY time_updated DESC LIMIT 100;" | head -15`