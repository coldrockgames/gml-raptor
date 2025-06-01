# 🛠️ Migration Guide: From `gml-raptor` to `gml-raptor-free`

Thank you for using `gml-raptor`! This short guide explains how to safely switch from the old repository (`gml-raptor`) to the new public version: **`gml-raptor-free`**.

---

## 🔄 Why the Rename?

We’ve restructured our GitHub repositories:

- `gml-raptor` → now **private**, used internally by our team
- `gml-raptor-free` → this **public** version for the open-source community

This change improves our development workflow while still giving you full access to the open version.

---

## 🧭 How to Migrate Your Local Clone

If you've cloned `gml-raptor` before, just update your Git remote like this:

### 🔧 Update your remote URL

```bash
git remote set-url origin https://github.com/coldrockgames/gml-raptor-free.git
```

That's it! Now you’re pulling and pushing to the correct public repo.

---

## 🧪 Optional: Rename Your Folder (for Clarity)

Your local folder might still be called `gml-raptor`. You can rename it if you'd like:

```bash
mv gml-raptor gml-raptor-free
```

Don’t forget to open the renamed folder in your GameMaker IDE afterward!

---

## 🧙‍ Troubleshooting

### Q: I forked `gml-raptor`. Do I need to re-fork?

> **A:** Yes. The old `gml-raptor` repo is now private. Please fork `gml-raptor-free` instead.

---

### Q: I get a "Repository not found" error when pulling or pushing.

> **A:** Update your remote using the command above. Your Git still points to the old private repo.

---

## 🙋 Need Help?

Feel free to open a Discussion or reach out via GitHub Issues.  
We're happy to assist you in migrating.

---

**Your Raptor Team** 🦖  
coldrock.games  
https://github.com/coldrockgames/gml-raptor-free
