# Insert this SQL

```
CREATE TABLE christmas_advent_claimed (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `identifier` VARCHAR(64) NOT NULL,
    `day` INT NOT NULL,
    `claimed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
)
```

# Add this to your qb-core > shared > items.lua
```
['carrot'] = {['name'] = 'carrot', ['label'] = 'Carrot', ['weight'] = 1000, ['type'] = 'item', ['image'] = 'carrot.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = ''},
```

You can use the image examples in the `/sql/item_images` folder.