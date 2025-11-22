CREATE TABLE christmas_advent_claimed (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(64) NOT NULL,
    `day` INT NOT NULL,
    `claimed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)