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
                                          + ', 1 )"><i class="fa fa-bookmark-o fa-fw"></i></a>' );
        }
        else
        {
          $('#bookmark_' + class_id).html( '<a onClick="BookmarkToggle( '
                                          + class_id
                                          + ', -1 )"><i class="fa fa-bookmark fa-fw"></i></a>' );
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
          $('#icon-' + mail_id).html( '<i class="fa fa-envelope-open"></i>' );
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
      jQuery( '#rating-' + rtnData[0].comment_id ).starrr({ readOnly: true, rating: values.rating });
      $( '#comment_count' ).html( function( i, val ) { return val*1 + 1 } );

      jQuery('#new_comment_rating').starrr({ rating: 0 });
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
        $( '#privacy-' + comment_id ).html( '<a class="button warning tiny" onClick="togglePublic(' + comment_id + ', 0);"><i class="fa fa-eye"></i> Make Public</a>' );
      }
      else
      {
        $( '#c' + comment_id ).removeClass( 'comment-section-body-private' );
        $( '#private-tag-' + comment_id ).html( '' );
        $( '#privacy-' + comment_id ).html( '<a class="button warning tiny" onClick="togglePublic(' + comment_id + ', 1);"><i class="fa fa-eye-slash"></i> Make Private</a>' );
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
