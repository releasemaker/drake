// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require foundation
//= require_tree .

jQuery(function() {
  jQuery(document).foundation();

  jQuery(document).on('click', 'button.add-repo', function(event) {
    const button = jQuery(event.target);
    const originalValue = button.value;
    event.preventDefault();

    button.value = button.data('disableWith') || 'working...';
    button.disabled = true;
    button.siblings('.failure').remove();

    jQuery.ajax({
      url: '/repos.json',
      method: 'POST',
      data: {
        repo: {
          type: button.data('type'),
          provider_uid_or_url: button.data('providerUidOrUrl'),
          name: button.data('name'),
        },
      },
    }).done(function(data, textStatus) {
      debugger;
      button.replaceWith(`<a href="${data.friendly_url}">Enabled</a>`);
    }).fail(function(jqXHR) {
      button.insertAfter('<span class="failure alert label">Failed</span>');
      button.disabled = false;
    });
  });
});
