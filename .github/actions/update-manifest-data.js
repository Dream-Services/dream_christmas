// 📂 Update Manifest Data
// 📝 By: ! Tuncion#0809
// 📝 Version: 1.0.0
// 📝 Date: 28.08.2023

const fs = require("fs");
const { execSync, exec } = require("child_process");

(async () => {
  const ReleaseType = process.env.RELEASE_TYPE;
  let ManifestFile = fs.readFileSync("fxmanifest.lua", { encoding: "utf8" });

  // Patch Version
  const Patch = process.env.RELEASE_PATCH;

  ManifestFile = ManifestFile.replace(
    /\bpatch\s+(.*)$/gm,
    `patch '#${Patch}'`
  );

  // Version
  const Version = ManifestFile.match(/\bversion\s+["']?([\d.]+)["']?/)[1] || "1.0.0";
  const NewVersion = NextVersionNo(Version);

  execSync(`RELEASE_VERSION=${NewVersion}\necho "RELEASE_VERSION=$RELEASE_VERSION" >> $GITHUB_ENV`);

  ManifestFile = ManifestFile.replace(
    /\bversion\s+(.*)$/gm,
    `version '${NewVersion}'`
  );

  // Released Date
  const ReleaseUser = process.env.RELEASE_USER;
  const CurrentDate = new Date();
  const options = {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    timeZone: 'Europe/Berlin', // Germany time zone
  };

  const NewReleaseDate = `${CurrentDate.toLocaleString('de-DE', options)} by ${ReleaseUser}`;

  ManifestFile = ManifestFile.replace(
    /\breleased\s+(.*)$/gm,
    `released '${NewReleaseDate}'`
  );

  // Update Fxmanifest
  fs.writeFileSync("fxmanifest.lua", ManifestFile, { encoding: "utf8" });
})();

/**
 * Increments the given version number by one patch version.
 * If the patch version exceeds 9, it resets to 0 and increments the minor version.
 * If the minor version exceeds 9, it resets to 0 and increments the major version.
 *
 * @param {string} version - The current version number in the format "major.minor.patch".
 * @returns {string} - The next version number in the format "major.minor.patch".
 */
function NextVersionNo(version) {
  let [major, minor, patch] = version.split(".").map(Number);
  patch++;
  if (patch > 9) {
    patch = 0;
    minor++;
  }
  if (minor > 9) {
    minor = 0;
    major++;
  }
  return `${major}.${minor}.${patch}`;
}