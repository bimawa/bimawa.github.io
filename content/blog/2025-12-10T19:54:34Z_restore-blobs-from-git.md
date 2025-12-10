+++
title = "Restore blobs from git"
description = "How to restore files from git which not in linked in index"
date = 2025-12-10T19:54:34Z
author = "Maxim Bunkov"
tags = ["git", "advice", "tool", "cheatsheet"]
template = "index.html"
+++

## Problem

Often thoughts come faster than actions, and once again I fell into this situation where I added files to the stage but forgot to commit, and immediately ran off to jump through commits using `git reset` and `git checkout`.

For those who are not yet familiar with this problem, `git reflog` won't help here. If you haven't done `git add .`, your last hope to recover files is only through:
- Time Machine
- Local changes if you're working in a JetBrains IDE
- Or if you're good at recovering data from an SSD
- etc

## Solution

The solution is available if you did `git add .`. This means Git has stored the blobs in its database but hasn't linked them to a specific commit. 
We can view these blobs:

```bash
git fsck --full --unreachable --no-reflog
```
This command will return all unstructured blobs that have no index.

We can examine each of them individually.

```bash
git cat-file -p <hash>
```
and save them to some file:
```bash
git cat-file -p <hash> > file.txt
```
But, as you've already guessed, this is not very convenient.

## Tooling

Let's create a more convenient script that does all this for us.

```bash

# Create a folder for recovered files
mkdir -p restored_blobs

# Find all dangling blobs and recover them
echo "Searching for lost files..."

# git fsck finds lost objects
# grep "dangling blob" filters only files (ignoring lost trees/commits)
# awk '{print $3}' extracts the hash
for blob in $(git fsck --lost-found | grep "dangling blob" | awk '{print $3}'); do
    echo "Recovering: $blob"
    git cat-file -p $blob > restored_blobs/$blob
done

echo "Done! Check the restored_blobs folder."
```

That's all. Now we just need to go through the files, figure out what's what, and put them where they originally were. Since the paths where they were located are not preserved, we'll have to do this manually.

## Conclusions

I hope this saves someone's life, because it has saved mine many times.
