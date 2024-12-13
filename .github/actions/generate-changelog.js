// 📂 Generate Changelog
// 📝 By: ! Tuncion#0809
// 📝 Version: 1.0.0
// 📝 Date: 13.12.2024

const fs = require("fs");
const { execSync, exec } = require("child_process");

(async () => {
    const ReleaseType = process.env.RELEASE_TYPE || 'Release';

    const Changelog = [];
    const Contributors = {};
    const LastTag = execSync(`git describe --tags --abbrev=0 HEAD^`).toString().trim();

    // All Commits since last tag
    const AllCommitsSinceLastTag = [];
    const GitLogSinceLastTag = execSync(`git log ${LastTag}..HEAD --pretty=format:"%H|%h|%s|%an|%ae|%ad"`)
        .toString()
        .trim()
        .split("\n");

    GitLogSinceLastTag.forEach((commit) => {
        const [hash, short_hash, message, author, email, date] = commit.split("|");
        AllCommitsSinceLastTag.push({ hash, short_hash, message, author, email, date });
        Contributors[email] = author;
    });

    // Whats's Changed
    Changelog.push(`## What's Changed`);

    const ChangedList = {
        chores: [],
        commits: [],
    };
    AllCommitsSinceLastTag.forEach((commit) => {
        if (commit.message.startsWith("chore:")) {
            ChangedList.chores.push(commit);
        } else {
            ChangedList.commits.push(commit);
        };
    });

    // Chore
    if (ChangedList.chores.length > 0) {
        Changelog.push(`### Chores:`);
        ChangedList.chores.forEach((commit) => {
            Changelog.push(`- ${commit.short_hash}: ${commit.message} ([${commit.author}](https://github.com/${commit.author.replaceAll(' ', '%20')}))`);
        });
    };

    // Commits
    Changelog.push(`### Commits:`);
    ChangedList.commits.forEach((commit) => {
        Changelog.push(`- ${commit.short_hash}: ${commit.message} ([${commit.author}](https://github.com/${commit.author.replaceAll(' ', '%20')}))`);
    });

    // Contributor
    Changelog.push(`\n## Contributors`);

    for (const [email, author] of Object.entries(Contributors)) {
        const response = await fetch(`https://api.github.com/users/${author}`);
        if (!response.ok) continue;
        const ContributorData = await response.json();
        if (!ContributorData || !ContributorData.avatar_url) continue;
        Changelog.push(`- [<img alt="${author}" src="${ContributorData.avatar_url}" width="20"> **${ContributorData.login}** (${ContributorData.name})](${ContributorData.html_url})`);
    };
    Changelog.push(`\n**Thank you for your contribution ❤️**`);

    // Disclaimer
    Changelog.push(`\n## Disclaimer`);

    if (ReleaseType == 'Release') {
        Changelog.push(`This is a **🚀 New Release** that may include experimental features or enhancements. Please review the changelog for details and test thoroughly.`);
    } else {
        Changelog.push(`This is a **🚨 Hotfix Release** designed to address issues. Please update to ensure optimal performance and stability.`);
    };

    // Save to file
    fs.writeFileSync(`./changelog.md`, Changelog.join('\n'), { encoding: "utf8" });
})();