echo "# Linux" > ../README.md
for file in *; do
    [ "$file" = "README.md" ] && continue
    [ "$file" = "generateREADME.sh" ] && continue

    # Check if it's a regular file (skips directories)
    [ -f "$file" ] || continue

    # ${file%.md} strips the .md extension from the header
    echo "## ${file%.md}\n" >> ../README.md
    cat "$file" >> ../README.md
    echo "\n---\n" >> ../README.md
    echo "\n---\n" >> ../README.md
    echo "\n---\n" >> ../README.md
done
