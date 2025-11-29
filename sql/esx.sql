CREATE TABLE christmas_advent_claimed (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(64) NOT NULL,
    `day` INT NOT NULL,
    `claimed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

-- See sql/item_images for item images examples
INSERT INTO `items` (`name`, `label`, `weight`) VALUES
    ('carrot', 'Carrot', 1)
;