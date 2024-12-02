// Open-Source Conditions
// Please read the license conditions in the LICENSE file. By using this script, you agree to these conditions.

window.addEventListener('message', async (event) => {
    const item = event.data;

    // Snow Overlay
    if (item.type === 'snow_overlay:show') {
        if ($('#snowfall-element').css('visibility') === 'hidden') $('#snowfall-element').css('visibility', 'visible'); // Show the snow overlay
        $('#snowfall-element').fadeIn(350);
    };

    if (item.type === 'snow_overlay:hide') {
        $('#snowfall-element').fadeOut(350);
    };

});