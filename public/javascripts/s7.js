function showSuccess( msg )
{
  notif(
    {
      msg:       "<i class='fa fa-check-circle fa-fw'></i> " + msg,
      type:      'success',
      position:  'center',
      width:     400,
      autohide:  true,
      opacity:   1.0,
      fade:      true,
      clickable: true,
      multiline: true,
    }
  );
}

function showWarning( msg )
{
  notif(
    {
      msg:       "<i class='fa fa-exclamation-circle fa-fw'></i> " + msg,
      type:      'warning',
      position:  'center',
      width:     400,
      autohide:  false,
      opacity:   1.0,
      fade:      true,
      multiline: true,
    }
  );
}

function showError( msg )
{
  notif(
    {
      msg:       '<i class="fa fa-exclamation-triangle fa-fw"></i> ' + msg,
      type:      'error',
      position:  'center',
      width:     400,
      autohide:  false,
      opacity:   1.0,
      fade:      true,
      multiline: true,
    }
  );
}

function showInfo( msg )
{
  notif(
    {
      msg:       '<i class="fa fa-info-circle fa-fw"></i> ' + msg,
      type:      'info',
      position:  'center',
      width:     400,
      autohide:  false,
      opacity:   1.0,
      fade:      true,
      multiline: true,
    }
  );
}

$('.upload-tooltip').tooltipster(
{
  content: '<i class="fa fa-spinner fa-pulse fa-fw"></i><span class="sr-only">Loading...</span>',
  contentAsHTML: true,
  theme: 'tooltipster-light',
  animation: 'fade',
  interactive: true,
  // 'instance' is basically the tooltip. More details in the "Object-oriented Tooltipster" section.
  functionBefore: function(instance, helper)
  {
    var $origin = $(helper.origin),
      dataOptions = $origin.attr('data-tooltipster');
    var upload_id = '';

    if ( dataOptions )
    {
      dataOptions = JSON.parse(dataOptions);
      $.each(dataOptions, function(name, option)
        {
          upload_id = option;
        }
      );
    }

    // we set a variable so the data is only loaded once via Ajax, not every time the tooltip opens
    if ($origin.data('loaded') !== true)
    {
      $.get('/upload-tooltip/' + upload_id, function(data)
        {
          // call the 'content' method to update the content of our tooltip with the returned data.
          // note: this content update will trigger an update animation (see the updateAnimation option)
          instance.content(data);

          // to remember that the data has been loaded
          $origin.data('loaded', true);
        }
      );
    }
  }
});
