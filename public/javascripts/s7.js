function showSuccess( msg )
{
  notif(
    {
      msg:       "<i class='far fa-check-circle success'></i> " + msg,
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
      msg:       "<i class='far fa-exclamation-circle warning'></i> " + msg,
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
      msg:       '<i class="far fa-exclamation-triangle alert"></i> ' + msg,
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
      msg:       '<i class="far fa-info-circle"></i> ' + msg,
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

function promptForDelete( item, url )
{
  Ply.dialog( 'confirm',
    {
      effect : "3d-flip[180,-180]" // fade, scale, fall, slide, 3d-flip, 3d-sign
    },
    'Are you sure you want to delete "' + item + '"?'
  )
  .always( function(ui)
    {
      if (ui.state)
      {
        window.location.href = url;
        return true;
      }
      else
      {
        return false;
      }
    }
  );
}

function tooltipInit( selector )
{
  $( selector ).tooltipster(
  {
    content: '<i class="far fa-spinner fa-pulse"></i><span class="sr-only">Loading...</span>',
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
}

$('.upload-tooltip').tooltipster(
{
  content: '<i class="far fa-spinner fa-pulse"></i><span class="sr-only">Loading...</span>',
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

function BookmarkToggle( class_id, action )
{
  var bookmark_url = "/bookmark_class/" + class_id + "/" + action;

  $.ajax(
    {
      url: bookmark_url,
      dataType: 'json',
      type: 'GET',
      success: function( data )
      {
        if ( data[0].success < 1 )
        {
            showError( data[0].message );
            return false;
        }
        if ( action == -1 )
        {
          $('#bookmark_' + class_id).html( '<a onClick="BookmarkToggle( '
                                          + class_id
                                          + ', 1 )"><i class="far fa-bookmark"></i></a>' );
        }
        else
        {
          $('#bookmark_' + class_id).html( '<a onClick="BookmarkToggle( '
                                          + class_id
                                          + ', -1 )"><span class="fa-layers fa-fw"><i class="far fa-bookmark"></i><i class="far fa-ban"></i></span></a>' );
        }
        showSuccess( data[0].message )
      },
      error: function()
      {
        showError( 'An error occurred, and we could not bookmark this Class. Please try again later.' )
      }
    }
  );
}

function selectMail( mail_id, folder )
{
  var get_mail_url = "/user/mail/" + mail_id + '/' + folder;

  $.ajax(
    {
      url: get_mail_url,
      dataType: 'json',
      type: 'GET',
      success: function( data )
      {
        if ( data[0].success < 1 )
        {
          showError( data[0].message );
          return false;
        }

        $('#user-mail-display').html( data[0].content );

        if ( data[0].increment == 1 )
        {
          var unread = $('span#unread-count').text();
          if ( unread < 99 )
          {
            $('span#notification-count').html( unread - 1 );
          }
          $('span#unread-count').html( unread - 1 );
          $('#icon-' + mail_id).html( '<i class="far fa-envelope-open"></i>' );
        }
      },
      error: function()
      {
        showError( '<strong>Wait, what??</strong><br>An error occurred, and we could not message you indicated. Please try again later.' )
      }
    }
  );
}

function selectFolder( folder )
{
  var get_folder_url = "/user/mail_folder/" + folder;

  $.ajax(
    {
      url: get_folder_url,
      dataType: 'json',
      type: 'GET',
      success: function( data )
      {
        if ( data[0].success < 1 )
        {
          showError( data[0].message );
          return false;
        }

        $('.user-mail-list-wrapper').html( data[0].mail_list );

        $('#folder-name').html( 'Folder: <small>' + folder + ' ( Messages: ' + data[0].mail_count + ' | Unread: <span id="unread-count">' + data[0].unread_count + '</span> )</small>' );
        $('#user-mail-display').html( '<div class="text-center"><h3>No Mail Selected</h3></div>' );
        $('#filter-mail').html( '<a class="button tiny warning" id="filter-button" onClick="filterFolder( \'' + folder + '\', 1 );">Hide System Messages</a>' );

      },
      error: function()
      {
        showError( '<strong>Wait, what??</strong><br>An error occurred, and we could not message you indicated. Please try again later.' )
      }
    }
  );
}

function filterFolder( folder, filter )
{
  var get_folder_url = "/user/mail_folder/" + folder + '/' + filter;

  $.ajax(
    {
      url: get_folder_url,
      dataType: 'json',
      type: 'GET',
      success: function( data )
      {
        if ( data[0].success < 1 )
        {
          showError( data[0].message );
          return false;
        }

        $('.user-mail-list-wrapper').html( data[0].mail_list );
        var filtered = ' (filtered)';
        var set_filter = 0;
        var filter_action = 'Show';

        if ( filter != 1 )
        {
          filtered = '';
          set_filter = 1;
          filter_action = 'Hide';
        }

        $('#folder-name').html( 'Folder' + filtered + ': <small>' + folder + ' ( Messages: ' + data[0].mail_count + ' | Unread: <span id="unread-count">' + data[0].unread_count + '</span> )</small>' );
        $('#user-mail-display').html( '<div class="text-center"><h3>No Mail Selected</h3></div>' );
        $('#filter-mail').html( '<a class="button tiny warning" id="filter-button" onClick="filterFolder( \'' + folder + '\', ' + set_filter + ' );">' + filter_action + ' System Messages</a>' );

      },
      error: function()
      {
        showError( '<strong>Wait, what??</strong><br>An error occurred, and we could not filter as you indicated. Please try again later.' )
      }
    }
  );
}

function composeMessage( mail_id )
{
  var url = "/user/newmail";
  if ( mail_id )
  {
    url = url + '/' + mail_id;
  }

  $.ajax(
    {
      url: url,
      dataType: 'json',
      type: 'GET',
      success: function( data )
      {
        if ( data[0].success < 1 )
        {
          showError( data[0].message );
          return false;
        }

        $('#user-mail-display').html( data[0].content );
      },
      error: function()
      {
        showError( '<strong>Wait, what??</strong><br>An error occurred, and we could not load the compose form. Please try again later.' )
      }
    }
  );
}

function input_autocomplete( field )
{
  var options =
  {

    url: function(phrase) {
      return "/util/username_ac";
    },

    getValue: function(element) {
      return element.username;
    },

    ajaxSettings: {
      dataType: "json",
      method: "GET",
      data: {
        dataType: "json"
      }
    },

    preparePostData: function(data) {
      data.phrase = $( field ).val();
      return data;
    },

    template: {
      type: "description",
      fields: {
        description: "full_name"
      }
    },

    list: {
      match: {
        enabled: true
      },
      sort: {
        enabled: true
      },
      showAnimation: {
        type: "slide", //normal|slide|fade
        time: 400,
        callback: function() {}
      },
      hideAnimation: {
        type: "slide", //normal|slide|fade
        time: 400,
        callback: function() {}
      },
      maxNumberOfElements: 10
    },

    theme: "plate-dark",
    requestDelay: 400
  };

  jQuery( field ).easyAutocomplete( options );
}

function validateAndSend( form )
{
  var url = $( form ).attr('action');
  var values = {
    recipient: document.querySelector('[name="recipient"]').value,
    subject: document.querySelector('[name="subject"]').value,
    body: CKEDITOR.instances['message_body'].getData()
  };

  $.ajax(
  {
    url: url,
    data: values,
    dataType: "json",
    method: "GET",
    success: function(rtnData)
    {
      if ( rtnData[0].success < 1 )
      {
        showError( rtnData[0].message );
        return false;
      }

      $('#user-mail-display').html( rtnData[0].content );
    },
    error: function()
    {
      showError( '<strong>Oh, man!</strong><br>An error occurred, and we could not send your message. Please try again later.' );
    }
  });
}

function getCheckedBoxes( form )
{
  var checkedValues = $("input:checkbox[name='delete_mail']:checked").map( function(){ return $(this).val() } ).get();
  //console.log( 'Checked Values: ' + checkedValues );
  return checkedValues;
}

function deleteMessages( ids )
{
  var url = '/user/mail/delete';

  var data = { delete_ids: [ ids ] };

  $.ajax(
  {
    url: url,
    data: data,
    dataType: "json",
    method: "GET",
    traditional: true,
    success: function(rtnData)
    {
      if ( rtnData[0].success < 1 )
      {
        showError( rtnData[0].message );
        return false;
      }

      $.each( ids, function(i,v) {
        $('#' + v).remove();
      });

      $('#user-mail-display').html( '<div class="text-center"><h3>No Mail Selected</h3></div>' );
      showSuccess( rtnData[0].message );
    },
    error: function()
    {
      showError( '<strong>Oh, man!</strong><br>An error occurred, and we could not delete anything. Please try again later.' );
    }
  });
}

function saveComment( form )
{
  var url = $( form ).attr('action');
  var values = {
    thread_id:  ( typeof document.querySelector('[name="reply_thread_id"]').value !== 'undefined' )
                ? document.querySelector('[name="reply_thread_id"]').value : '',
    rating:     ( typeof document.querySelector('[name="rating"]').value !== 'undefined' )
                ? document.querySelector('[name="rating"]').value : 0,
    private:    ( $('input[name="private"]').prop('checked') == true )
                ? 1 : 0,
    comment:    CKEDITOR.instances['new_comment'].getData()
  };

  $.ajax(
  {
    url: url,
    data: values,
    dataType: "json",
    method: "POST",
    success: function(rtnData)
    {
      if ( rtnData[0].success < 1 )
      {
        showError( rtnData[0].message );
        return false;
      }

      if ( typeof thread_id !== 'undefined' && thread_id !== '' )
      {
        $( '#t' + thread_id ).append( rtnData[0].content );
      }
      else
      {
        $( '#comment-container' ).append( '<div id="' + rtnData[0].thread_id + '">' + rtnData[0].content + '</div>' );
      }
      jQuery( '#rating-' + rtnData[0].comment_id )
        .barrating(
          {
            theme: 'fontawesome-stars',
            initialValue: values.rating,
            readonly: true
          }
        );

      $( '#comment_count' ).html( function( i, val ) { return val*1 + 1 } );

      jQuery('#new_comment_rating')
        .barrating(
          {
            theme: 'fontawesome-stars',
            initialRating: 0,
            showValues: false,
            showSelectedRating: true,
            allowEmpty: true,
            deselectable: true,
            onSelect:function(value, text, event)
            {
              console.log( 'Selected ' + value );
              jQuery('#new_rating').val( value );
            }
          }
        );
      $('input[name="reply_thread_id"]').val( '' );
      $('input[name="private"]').prop("checked", false);
      CKEDITOR.instances['new_comment'].setData('');
      showSuccess( rtnData[0].message );
    },
    error: function()
    {
      showError( '<strong>Oh, man!</strong><br>An error occurred, and we could not save your comment. Please try again later.' );
    }
  });
}

function quoteComment( thread_id, comment_id, is_private, commenter )
{
  var quote = $( '#comment-' + comment_id ).html();
  if ( typeof commenter == 'undefined' ) { commenter = 'Unknown User'; }

  CKEDITOR.instances['new_comment'].setData( commenter + ' wrote:<br>\n<blockquote>' + quote + '</blockquote>', function()
    {
      this.checkDirty();  // true
    }
  );

  if ( is_private == 1 )
  {
    $('input[name="private"]').prop("checked", true);
  }
  else
  {
    $('input[name="private"]').prop("checked", false);
  }

  $('input[name="reply_thread_id"]').val( thread_id );

  scrollToAnchor( '#comment-form' );
}

function deleteComment( content_id, comment_id )
{
  var url = '/content/' + content_id + '/comment/' + comment_id + '/delete';

  $.ajax(
  {
    url: url,
    method: "GET",
    dataType: 'json',
    success: function( data )
    {
      if (  data[0].success < 1 )
      {
        showError(  data[0].message );
        return false;
      }

      $( '#c' + comment_id ).remove();
      $( '#comment_count' ).html( function( i, val ) { return val*1 - 1 } );

      showSuccess(  data[0].message );
    },
    error: function()
    {
      showError( '<strong>Oh, man!</strong><br>An error occurred, and we could not delete your comment. Please try again later.' );
    }
  });
}

function togglePublic( comment_id, mode )
{
  if ( typeof comment_id == 'undefined' )
  {
    return false;
  }

  if ( typeof mode == 'undefined' ) { mode = 1; }

  var url = '/comment/toggle_privacy/' + comment_id + '/' + mode;

  $.ajax(
  {
    url: url,
    method: "GET",
    dataType: 'json',
    success: function( data )
    {
      if (  data[0].success < 1 )
      {
        showError(  data[0].message );
        return false;
      }

      if ( mode == 1 )
      {
        $( '#c' + comment_id ).addClass( 'comment-section-body-private' );
        $( '#private-tag-' + comment_id ).html( '<h6>PRIVATE COMMENT</h6>' );
        $( '#privacy-' + comment_id ).html( '<a class="button warning tiny" onClick="togglePublic(' + comment_id + ', 0);"><i class="far fa-eye"></i> Make Public</a>' );
      }
      else
      {
        $( '#c' + comment_id ).removeClass( 'comment-section-body-private' );
        $( '#private-tag-' + comment_id ).html( '' );
        $( '#privacy-' + comment_id ).html( '<a class="button warning tiny" onClick="togglePublic(' + comment_id + ', 1);"><i class="far fa-eye-slash"></i> Make Private</a>' );
      }

      showSuccess(  data[0].message );
    },
    error: function()
    {
      showError( '<strong>Oh, man!</strong><br>An error occurred, and we could not change the privacy your comment. Please try again later.' );
    }
  });
}

function scrollToAnchor( aid )
{
  var aTag = $( aid );
  $('html,body').animate({scrollTop: aTag.offset().top},'slow');
}

function toggleFilter( element, id )
{
  if (element.checked)
  {
    $("#filter-indicator-" + id).html( '<strong>Filtered</strong>' );
  }
  else
  {
    $("#filter-indicator-" + id).html( 'Unfiltered' );
  }
}

function toggleFilterRow( id )
{
  var input_id = '#filter-' + id;
  var wrap_id  = '#indicator-wrap-' + id;
  if ($(input_id).prop( 'checked' ))
  {
    $(input_id).attr( 'checked', false );
    $(wrap_id).html( 'Unfiltered' );
    $(wrap_id).removeClass( 'warning' ).addClass( 'primary' );
  }
  else
  {
    $(input_id).attr( 'checked', true );
    $(wrap_id).html( 'Filtered' );
    $(wrap_id).removeClass( 'primary' ).addClass( 'warning' );
  }
}

$(function()
{
  /*
  * For the sake keeping the code clean and the examples simple this file
  * contains only the plugin configuration & callbacks.
  *
  * UI functions ui_* can be located in: demo-ui.js
  */
  $('#avatar-uploader').dmUploader(
  {
    url: '/user/avatar/upload',
    dnd: true,
    auto: false,
    maxFileSize: 3000000, // 3 Megs
    multiple: false,
    dataType: 'json',
    fieldName: 'filename',
    allowedTypes: "image/*",
    extFilter: ["jpg", "jpeg", "png", "gif"],
    extraData: function() {
      return {
        "title": $('#avatar-title').val()
      };
    },

    onDragEnter: function()
    {
      // Happens when dragging something over the DnD area
      this.addClass('active');
    },
    onDragLeave: function()
    {
      // Happens when dragging something OUT of the DnD area
      this.removeClass('active');
    },
    onInit: function()
    {
      // Plugin is ready to use
      console.log('Avatar Upload initialized :)');
    },
    onComplete: function()
    {
      // All files in the queue are processed (success or error)
      console.log('All pending tranfers finished');
    },
    onNewFile: function(id, file)
    {
      // When a new file is added using the file selector or the DnD area
      console.log('New file added #' + id);
      ui_multi_add_file(id, file);
    },
    onBeforeUpload: function(id)
    {
      // about tho start uploading a file
      console.log('Starting the upload of #' + id);
      ui_multi_update_file_status(id, 'label', 'Uploading...');
      ui_multi_update_file_progress(id, 0, '', true);
    },
    onUploadCanceled: function(id)
    {
      // Happens when a file is directly canceled by the user.
      ui_multi_update_file_status(id, 'label warning', 'Canceled by User');
      ui_multi_update_file_progress(id, 0, 'warning', false);
    },
    onUploadProgress: function(id, percent)
    {
      // Updating file progress
      ui_multi_update_file_progress(id, percent);
    },
    onUploadSuccess: function(id, data)
    {
      // A file was successfully uploaded
      console.log('Server Response for file #' + id + ': ' + JSON.stringify(data));
      console.log('Upload of file #' + id + ' COMPLETED', 'success');
      ui_multi_update_file_status(id, 'label success', 'Upload Complete');
      ui_multi_update_file_progress(id, 100, 'success', false);
      $('#avatar-title').val( '' );
      reload_user_avatars();
      setTimeout(function() { $('#file-status').find('span').html( '' ).prop('class', ''); }, 5000);
    },
    onUploadError: function(id, xhr, status, message)
    {
      showError( '<strong>Danger, Will Robinson!</strong><br>' + message );
      ui_multi_update_file_progress(id, 0, 'alert', false);
    },
    onFallbackMode: function()
    {
      // When the browser doesn't support this plugin :(
      console.log('Plugin cannot be used here, running Fallback callback');
    },
    onFileSizeError: function(file)
    {
      showError( '<strong>Look at the <em>size</em> of that thing!</strong><br>File \''
                  + file.name + '\' cannot be added as it exceeds the size limit of 3Mb.' );
      console.log('File \'' + file.name + '\' cannot be added: size excess limit');
    }
  });
});

 /*
 * Some helper functions to work with our UI and keep our code cleaner
 */

// Creates a new file and add it to our list
function ui_multi_add_file(id, file)
{
  var template = $('#files-template').text();
  template = template.replace('%%filename%%', file.name);

  template = $(template);
  template.prop('id', 'uploaderFile' + id);
  template.data('file-id', id);

  $('#files').find('li.empty').fadeOut(); // remove the 'no files yet'
  $('#files').prepend(template);
}

// Changes the status messages on our list
function ui_multi_update_file_status(id, status, message)
{
  $('#file-status').find('span').html(message).prop('class', status);
}

// Updates a file progress, depending on the parameters it may animate it or change the color.
function ui_multi_update_file_progress(id, percent, color, active)
{
  color  = (typeof color === 'undefined' ? false : color);

  var bar_wrap = $('#avatar-upload');
  var bar      = $('#avatar-upload').find('span.progress-meter');
  var bar_text = $('#avatar-upload').find('p.progress-meter-text');

  bar_wrap.attr('aria-valuenow', percent);
  bar.width(percent + '%');

  if (percent === 0)
  {
    bar_text.html('');
  }
  else
  {
    bar_text.html(percent + '%');
  }

  if (color !== false)
  {
    bar.removeClass('success secondary primary warning error');
    bar.addClass(color);
  }
}

function reload_user_avatars()
{
  var url='/user/avatars/refresh';

  $.ajax(
  {
    url: url,
    method: "GET",
    dataType: 'html',
    success: function( data )
    {
      $('#user-avatars').html( data );
      // Initialize
      var bLazy = new Blazy(
        {
          container: '#user-avatars',
          selector: '#user-avatars, .b-lazy, img.b-lazy',
          loadInvisibe: true,
          offset: 1,
          success: function(ele)
          {
            // Image has loaded
            // console.log( 'Blazy Loaded image.' );
          },
          error: function(ele, msg)
          {
            if ( msg === 'missing' )
            {
              // Data-src is missing
              console.log( 'Blazy Data-src is missing.' );
            }
            else if ( msg === 'invalid' )
            {
              // Data-src is invalid
              console.log( 'Blazy Data-src is invalid.' );
            }
          }
        }
      );
      console.log( 'Revalidating user-avatars');
      bLazy.load('img'); // reload lazy loaded images
    }
  });

}


//Generic functionality that doesn't use named functions
$(document).ready( function($)
  {

    if ( jQuery('#recents').length )
    {
      jQuery('#recents').infiniteScroll(
        {
          path   : '/browse/recents/{{#}}',
          append : '.upload-thumbnail',
          history: 'append'
        }
      );

      jQuery('#recents').on( 'load.infiniteScroll', function( event, response, path ) {
        var bLazy = new Blazy();
        bLazy.revalidate();
        tooltipInit( '.upload-tooltip' );
      });
    }

    $(document).on('submit', '#filter-categories-form', function(e)
      {
        var url = '/user/settings/filter/categories/update';
        console.log( 'URL: ' + url );

        $.ajax(
        {
          url: url,
          method: "POST",
          dataType: 'json',
          data: $( '#filter-categories-form' ).serialize(),
          success: function( data )
          {
            if (  data[0].success < 1 )
            {
              console.log( 'received error' );
              showError(  data[0].message );
              return false;
            }

            console.log( 'showing success' );
            showSuccess(  data[0].message );
          },
          error: function()
          {
            console.log( 'functional error' );
            showError( '<strong>Well, that\'s not good.</strong><br>An error occurred, and we could not update your filters. Please try again later.' );
          }
        });

        e.preventDefault();
      }
    );

    $(document).on('submit', '#filter-ratings-form', function(e)
      {
        var url = '/user/settings/filter/ratings/update';
        console.log( 'URL: ' + url );

        $.ajax(
        {
          url: url,
          method: "POST",
          dataType: 'json',
          data: $( '#filter-ratings-form' ).serialize(),
          success: function( data )
          {
            if (  data[0].success < 1 )
            {
              console.log( 'received error' );
              showError(  data[0].message );
              return false;
            }

            console.log( 'showing success' );
            showSuccess(  data[0].message );
          },
          error: function()
          {
            console.log( 'functional error' );
            showError( '<strong>Well, that\'s not good.</strong><br>An error occurred, and we could not update your filters. Please try again later.' );
          }
        });

        e.preventDefault();
      }
    );

    $('#avatar-start-upload').on('click', function(evt)
    {
      evt.preventDefault();

      $('#avatar-uploader').dmUploader('start');
    });

    $('#avatar-stop-upload').on('click', function(evt)
    {
      evt.preventDefault();

      $('#avatar-uploader').dmUploader('cancel');
    });

    $('#user-avatar-delete').on('click', function(evt)
    {
      var deleteIDs = [];

      // Collected all checked avatars
      $("input[name|='uadelete']").each( function( i, el )
        {
          if ( $(el).prop( "checked" ) )
          {
            var id = el.name.substring(9);
            deleteIDs.push( id );
            // console.log( 'Added ID ' + id + ' to the delete list.' );
          }
        }
      );

      jQuery.confirm(
        {
          title: 'Delete avatars?',
          content: 'Are you sure you want to delete th'
                    + (( deleteIDs.length === 1 ) ? 'is ' : 'ese ')
                    + deleteIDs.length + ' avatar'
                    + (( deleteIDs.length === 1 ) ? '' : 's') + '?',
          type: 'red',
          theme: 'light',
          icon: 'far fa-exclamation-triangle',
          useBootstrap: false,
          buttons:
          {
            confirm: function ()
            {

              // console.log( deleteIDs );
              // Send all avatar IDs to route
              $.ajax(
              {
                url: '/user/avatars/delete',
                method: "POST",
                dataType: 'json',
                data: { to_delete: deleteIDs },
                success: function( data )
                {
                  if ( data[0].success < 1 )
                  {
                    console.log( 'received error' );
                    showError(  data[0].message );
                    return false;
                  }

                  console.log( 'showing success' );
                  showSuccess( data[0].message );
                  // Refresh user-avatars div
                  reload_user_avatars();
                },
                error: function()
                {
                  console.log( 'functional error' );
                  showError( '<strong>Well, that\'s not good.</strong><br>An error occurred, and we could not delete your avatars. Please try again later.' );
                }
              });

            },
            cancel: function ()
            {
            }
          }
        }
      );
    });

    $('#avatar-select-form').on('submit', function(evt)
      {
        evt.preventDefault();

        $.ajax(
          {
            url: '/user/avatar/select',
            method: 'POST',
            dataType: 'json',
            data: $( '#avatar-select-form' ).serialize(),
            success: function( data )
            {
              if ( data[0].success < 1 )
              {
                console.log( 'avatar select received error' );
                showError(  data[0].message );
                return false;
              }

              console.log( 'showing success' );
              showSuccess( data[0].message );
              // Refresh user-avatars div
              $('#current-avatar').html('<img src="' + data[0].uri + '" class="avatar-100">');
            },
            error: function()
            {
              console.log( 'avatar select functional error' );
              showError( '<strong>Well, that\'s not good.</strong><br>An error occurred, and we could not save your avatar selection. Please try again later.' );
            }
          }
        );
      }
    );

    $('#user-profile-form')
      .on("forminvalid.zf.abide", function(ev,frm) {
          console.log("Form id "+ev.target.id+" is invalid");
          showError( 'You have errors in your form.' );
          return false;
        }
      )
      .on("formvalid.zf.abide", function(ev,frm)
        {
          console.log("Form id "+frm.attr('id')+" is valid");
          // ajax post form
          $.ajax(
            {
              url: '/user/profile/update',
              method: 'POST',
              dataType: 'json',
              data: $( '#user-profile-form' ).serialize(),
              success: function( data )
              {
                if ( data[0].success < 1 )
                {
                  console.log( 'profile update received error' );
                  showError( data[0].message );
                  return false;
                }

                console.log( 'showing profile update success' );
                showSuccess( data[0].message );
              },
              error: function()
              {
                console.log( 'avatar select functional error' );
                showError( '<strong>Well, that\'s not good.</strong><br>An error occurred, and we could not update your profile. Please try again later.' );
              }
            }
          );
        }
      )
      .on('submit', function(ev,frm)
        {
          ev.preventDefault();
          console.log("Submit for form id "+ev.target.id+" intercepted");
        }
      );

    (function()
      {
        // Initialize
        var bLazy = new Blazy(
          {
            selector: '.b-lazy, img.b-lazy',
            container: '#page-content',
            success: function(ele)
            {
              // Image has loaded
              // console.log( 'Blazy Loaded image.' );
            },
            error: function(ele, msg)
            {
              if ( msg === 'missing' )
              {
                // Data-src is missing
                console.log( 'Blazy Data-src is missing.' );
              }
              else if ( msg === 'invalid' )
              {
                // Data-src is invalid
                console.log( 'Blazy Data-src is invalid.' );
              }
            }
          }
        );
      }
    )();

  }
);
