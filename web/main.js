// Open-Source Conditions
// Please read the license conditions in the LICENSE file. By using this script, you agree to these conditions.

let Locales = null;

// UI Ready
window.addEventListener('load', async (event) => {
    $.post(`https://${GetParentResourceName()}/readyUI`, JSON.stringify({}));
});

window.addEventListener('message', async (event) => {
    const item = event.data;

    // Startup
    if (item.type == 'startup') {
        Locales = item.locales;
    };

    // Activity Popup
    if (item.type === 'activity_popup:start') {
        const variant = item.variant;
        if (!variant) return console.log('No variant specified for activity popup.');

        if (variant === 'present') {
            $('.activity-popup-circle').css('background', '#BE3636');
            $('.activity-popup-img').attr('src', './assets/img/present.png');
            $('.activity-popup-text').css('margin-top', '13.5vh');
            $('.activity-popup-text').text(Locales['ChristmasPresent']['Claim']['ActivityPopup']);
            $('.activity-popup').fadeIn(350);
        } else if (variant === 'tree') {
            $('.activity-popup-circle').css('background', '#2F5A2C');
            $('.activity-popup-img').attr('src', './assets/img/tree.png');
            $('.activity-popup-text').css('margin-top', '17vh');
            $('.activity-popup-text').text(Locales['ChristmasTree']['Decorate']['ActivityPopup']);
            $('.activity-popup').fadeIn(350);
        } else if (variant === 'randomprop_snowman') {
            $('.activity-popup-circle').css('background', '#2677D3');
            $('.activity-popup-img').attr('src', './assets/img/snowman.png');
            $('.activity-popup-text').css('margin-top', '17vh');
            $('.activity-popup-text').text(Locales['PropSystem']['ActivityPopup']['snowman']);
            $('.activity-popup').fadeIn(350);
        } else {
            return console.log("Unknown activity popup variant.");
        };
    };

    if (item.type === 'activity_popup:stop') {
        $('.activity-popup').fadeOut(350);
    };

    // Snow Overlay
    if (item.type === 'snow_overlay:show') {
        if ($('#snowfall-element').css('visibility') === 'hidden') $('#snowfall-element').css('visibility', 'visible'); // Show the snow overlay
        $('#snowfall-element').fadeIn(350);
    };

    if (item.type === 'snow_overlay:hide') {
        $('#snowfall-element').fadeOut(350);
    };

});