// Open-Source Conditions
// Please read the license conditions in the LICENSE file. By using this script, you agree to these conditions.

let Locales = null;
let DotInterval = null;

function OpenDoor(doorElement) {
    if (!doorElement.classList.contains('doorOpen')) {
        const TodayDay = new Date().getDate();
        const TodayMonth = new Date().getMonth() + 1;
        if (
            TodayDay == Number(doorElement.getAttribute('data-day-id'))
            && TodayMonth == 12
        ) {
            doorElement.classList.add('doorOpen');
            doorElement.parentNode.querySelector('.advent-calendar-status-ribbon').classList.remove('not-claimed');
            doorElement.parentNode.querySelector('.advent-calendar-status-ribbon').classList.add('claimed');
            doorElement.parentNode.querySelector('.advent-calendar-status-ribbon span').innerText = Locales['AdventCalendar']['Status']['Claimed'];
            $.post(`https://${GetParentResourceName()}/claimAdventDoor`, JSON.stringify({
                dayId: Number(doorElement.getAttribute('data-day-id'))
            }));
        }
    }
}

// UI Ready
window.addEventListener('load', async (event) => {
    $.post(`https://${GetParentResourceName()}/readyUI`, JSON.stringify({}));
});

window.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        CloseUI();
    };
});

function CloseUI() {
    $('.advent-calendar').fadeOut(350);
    $.post(`https://${GetParentResourceName()}/closeUI`, JSON.stringify({}));
}

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

    // Progress Bar
    if (item.type === 'progress_bar:start') {
        $('.progress-bar-text').text(item.label);
        $('.progress-bar-bar-fill').css({ transition: 'width 0s linear' });
        $('.progress-bar-bar-fill').css({ width: '0%' });
        $('.progress-bar-bar-fill').css({ transition: `width ${item.duration}ms linear` });
        $('.progress-bar').fadeIn(350);
        $('.progress-bar-bar-fill').css({ width: '100%' });

        if (item.enableDotsAnimation) {
            const DotsAnimation = ['.', '..', '...'];
            let DotIndex = 0;
            DotInterval = setInterval(() => {
                $('.progress-bar-text').text(item.label + DotsAnimation[DotIndex]);
                DotIndex = (DotIndex + 1) % DotsAnimation.length;
            }, 500);
        };

        setTimeout(() => {
            $('.progress-bar').fadeOut(300);
            if (DotInterval) {
                clearInterval(DotInterval);
                DotInterval = null;
            };
        }, item.duration + 300);
    };

    if (item.type === 'progress_bar:stop') {
        $('.progress-bar').fadeOut(300);
        if (DotInterval) {
            clearInterval(DotInterval);
            DotInterval = null;
        };
    };

    // Advent Calendar
    if (item.type === 'advent_calendar:show') {
        const data = item.data;
        const TodayDay = new Date().getDate();
        const TodayMonth = new Date().getMonth() + 1;

        // Random Sequence
        const AdventCalendarDays = [];
        let CurrentSequence = JSON.parse(localStorage.getItem('AdventCalendarSequence')) || null;
        if (CurrentSequence) {
            CurrentSequence.forEach((dayId) => {
                const DayData = data.find(day => day.id === dayId);
                if (DayData) AdventCalendarDays.push(DayData);
            });
        } else {
            const DayIndices = Array.from({ length: data.length }, (_, i) => i);
            while (DayIndices.length > 0) {
                const RandomIndex = Math.floor(Math.random() * DayIndices.length);
                const DayIndex = DayIndices.splice(RandomIndex, 1)[0];
                AdventCalendarDays.push(data[DayIndex]);
            };
            localStorage.setItem('AdventCalendarSequence', JSON.stringify(AdventCalendarDays.map(day => day.id)));
        };

        // Create Doors
        $('.advent-calendar-doors').empty();
        AdventCalendarDays.forEach((day) => {
            $('.advent-calendar-doors').append(`
                <div class="advent-calendar-door-wrapper ${day.isToday ? 'doorToday' : ''}">
                    <div class="advent-calendar-backdoor noselect">
                        <div class="advent-calendar-status-ribbon ${day.isClaimed ? 'claimed' : 'not-claimed'}">
                            <span>${day.isClaimed ? Locales['AdventCalendar']['Status']['Claimed'] : Locales['AdventCalendar']['Status']['NotClaimed']}</span>
                        </div>
                        <img class="advent-calendar-backdoor-content-img" src="${day.image}">
                        <p class="advent-calendar-backdoor-content-text">${day.label}</p>
                    </div>
                    <div class="advent-calendar-door ${day.isClaimed
                    || (
                        day.id < TodayDay
                        && TodayMonth == 12
                    )
                    ? 'doorOpen' : ''
                }" onclick="OpenDoor(this)" data-day-id="${day.id}">
                        <p class="advent-calendar-backdoor-text noselect">${day.id}</p>
                    </div>
                </div>
            `);
        });

        $('.advent-calendar').fadeIn(350);
    };

    if (item.type === 'advent_calendar:hide') {
        $('.advent-calendar').fadeOut(350);
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