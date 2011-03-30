/*
 *  xlist.c
 *  libetpan
 *
 *  Created by DINH Viêt Hoà on 30/3/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "xlist.h"

#include "mailimap.h"
#include "mailimap_extension.h"
#include "mailimap_sender.h"

static int mailimap_xlist_send(mailstream * fd,
                               const char * mb, const char * list_mb)
{
  int r;
  
  r = mailimap_token_send(fd, "XLIST");
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  r = mailimap_space_send(fd);
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  r = mailimap_mailbox_send(fd, mb);
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  r = mailimap_space_send(fd);
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  r = mailimap_list_mailbox_send(fd, list_mb);
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  return MAILIMAP_NO_ERROR;
}

LIBETPAN_EXPORT
int mailimap_xlist(mailimap * session, const char * mb,
                   const char * list_mb, clist ** result)
{
  struct mailimap_response * response;
  int r;
  int error_code;
  
  if ((session->imap_state != MAILIMAP_STATE_AUTHENTICATED) &&
      (session->imap_state != MAILIMAP_STATE_SELECTED))
    return MAILIMAP_ERROR_BAD_STATE;
  
  r = mailimap_send_current_tag(session);
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  r = mailimap_xlist_send(session->imap_stream, mb, list_mb);
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  r = mailimap_crlf_send(session->imap_stream);
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  if (mailstream_flush(session->imap_stream) == -1)
    return MAILIMAP_ERROR_STREAM;
  
  if (mailimap_read_line(session) == NULL)
    return MAILIMAP_ERROR_STREAM;
  
  r = mailimap_parse_response(session, &response);
  if (r != MAILIMAP_NO_ERROR)
    return r;
  
  * result = session->imap_response_info->rsp_mailbox_list;
  session->imap_response_info->rsp_mailbox_list = NULL;
  
  error_code = response->rsp_resp_done->rsp_data.rsp_tagged->rsp_cond_state->rsp_type;
  
  mailimap_response_free(response);
  
  switch (error_code) {
    case MAILIMAP_RESP_COND_STATE_OK:
      return MAILIMAP_NO_ERROR;
      
    default:
      return MAILIMAP_ERROR_LIST;
  }
}

