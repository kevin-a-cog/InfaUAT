global class ConnectApiFeedElementHelper {
    /*
Copyright (c) 2018, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
* Neither the name of the salesforce.com, Inc. nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
*/
    
    /**
*
* Helper class that makes it easier to do common operations with the classes in the ConnectApi namespace.
*
* Includes convenience methods to:
*
*     - Post Chatter @-mentions, rich text, and inline images with Apex code.
*     - Take a feed item or comment body and return an input body that matches it.
*       This is useful for when you retrieve a feed item or comment and want to either
*       re-post or edit it.
*
* This class works with API version 43.0 and later. There are separate classes
* that work with v42.0 and earlier.
*
* See https://github.com/forcedotcom/ConnectApiHelper for more information.
*
*/
    
    
    public class InvalidParameterException extends Exception {}
    
    private static final Map<String, ConnectApi.MarkupType> supportedMarkup = new Map<String, ConnectApi.MarkupType> {
        'b' => ConnectApi.MarkupType.Bold,
            'code' => ConnectApi.MarkupType.Code,
            'i' => ConnectApi.MarkupType.Italic,
            'li' => ConnectApi.MarkupType.ListItem,
            'ol' => ConnectApi.MarkupType.OrderedList,
            'p' => ConnectApi.MarkupType.Paragraph,
            's' => ConnectApi.MarkupType.Strikethrough,
            'u' => ConnectApi.MarkupType.Underline,
            'ul' => ConnectApi.MarkupType.UnorderedList,
            'a' => ConnectApi.MarkupType.Hyperlink
            };
                

    
    /**
* Posts a feed item with rich text using HTML tags and inline image formatting syntax.
*
* @param communityId Use either the ID of a community, 'internal', or null.
* @param subjectId The parent of the post. Can be a user ID, a group ID, or a record ID.
* @param textWithMentionsAndRichText The text of the post. You can @-mention a
*                         user or group by using the syntax {ID}, for example:
*                         'Hello {005x0000000URNP}, have you seen the group {0F9x00000000D7m}?'
*                         You can include rich text by using supported HTML tags:
*                         <b>, <i>, <u>, <s>, <ul>, <ol>, <li>, <p>, <code>.
*                         You can include an inline image by using the syntax {img:ID} or
*                         {img:ID:alt text}, for example: 'Have you seen this gorgeous view?
*                         {img:069x00000000D7m:View of the Space Needle from our office.}?'
*                         Links and hashtags will be automatically parsed if provided.
* @return The posted feed item.
*/
    public static ConnectApi.FeedElement postFeedItemWithRichText(String communityId, String subjectId, String textWithMentionsAndRichText) {
        return postFeedItemWithSpecialFormatting(communityId, subjectId, textWithMentionsAndRichText, 'textWithMentionsAndRichText');
    }
    
    private static ConnectApi.FeedElement postFeedItemWithSpecialFormatting(String communityId, String subjectId, String formattedText, String textParameterName) {
        if (formattedText == null || formattedText.trim().length() == 0) {
            throw new InvalidParameterException('The ' + textParameterName + ' parameter must be non-empty.');
        }
        
        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = getMessageSegmentInputs(formattedText);
        
        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.body = messageInput;
        input.subjectId = subjectId;
        
        return ConnectApi.ChatterFeeds.postFeedElement(communityId, input);
    }
    
    /**
* Posts a comment with @-mentions using an @-mention formatting syntax.
*
* @param communityId Use either the ID of a community, 'internal', or null.
* @param feedItemId The ID of the feed item being commented on.
* @param textWithMentions The text of the comment. You can @-mention a user or group by using
*                         the syntax {ID}, for example: 'Hello {005x0000000URNP}, have you
*                         seen the group {0F9x00000000D7m}?' Links and hashtags will be
*                         automatically parsed if provided.
* @return The posted comment.
*/

    public static List<ConnectApi.MessageSegmentInput> getMessageSegmentInputs(String inputText) {
        if (inputText == null) {
            throw new InvalidParameterException('The inputText parameter cannot be null.');
        }
        
        List<ConnectApi.MessageSegmentInput> messageSegmentInputs = new List<ConnectApi.MessageSegmentInput>();
        Integer strPos = 0;
        // The pattern for matching mentions, markup begin/end tags, and inline images.
        // The first group matches a 15 or 18 character ID surrounded by {}:
        //   (\\{[a-zA-Z0-9]{15}\\}|\\{[a-zA-Z0-9]{18}\\})
        // The second/third groups match beginning/ending HTML tags: (<[a-zA-Z]*>)|(</[a-zA-Z]*>)
        // The fourth group matches a 15 or 18 character content document ID preceded by "img:",
        //    optionally followed by a string (not containing '}'), and surrounded by {}:
        //    (\\{img:(069[a-zA-Z0-9]{12,15})(:[\\s\\S]*?)?\\})
        // The fifth group matches a 15 or 18 character record ID preceded by "record:" ex:{record:01t3E000002GCm9QAG}
        Pattern globalPattern = Pattern.compile('(\\{[a-zA-Z0-9]{15}\\}|\\{[a-zA-Z0-9]{18}\\})|(<[a-zA-Z]*>)|(<[a-zA-Z](.+?)>)|(</[a-zA-Z]*>)|(\\{img:(069[a-zA-Z0-9]{12,15})(:[\\s\\S]*?)?\\})|(\\{record:([a-zA-Z0-9]){15,18}(:[\\s\\S]*?)?\\})');
        Matcher globalMatcher = globalPattern.matcher(inputText);
        Boolean isTextFollowedByLink = false;
        ConnectApi.MarkupBeginSegmentInput markupBeginSegmentInputUpdate;
        while (globalMatcher.find()) {

            String textSegment = inputText.substring(strPos, globalMatcher.start());
            String matchingText = globalMatcher.group();

            System.debug('textSegment > ' + textSegment);
            System.debug('matchingText > ' + matchingText);

            if (matchingText.startsWith('{')) {
                // Add a segment for any accumulated text (which includes unsupported HTML tags).
                addTextSegment(messageSegmentInputs, textSegment);
                
                // Strip off the { and }.
                String innerMatchedText = matchingText.substring(1, matchingText.length() - 1);
                
                if (innerMatchedText.startsWith('img:')) {
                    // This is an inline image.
                    String[] imageInfo = innerMatchedText.split(':', 3);
                    String altText = imageInfo.size() == 3 ? imageInfo[2] : null;
                    ConnectApi.InlineImageSegmentInput inlineImageSegmentInput = makeInlineImageSegmentInput(imageInfo[1], altText);
                    messageSegmentInputs.add(inlineImageSegmentInput);
                    strPos = globalMatcher.end();
                }
                else if (innerMatchedText.startsWith('record:')) {
                    // Inline record
                    String[] recordInfo = innerMatchedText.split(':');
                    ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = makeEntityLinkSegmentInput(recordInfo[1]);
                    messageSegmentInputs.add(entityLinkSegmentInput);
                    strPos = globalMatcher.end();
                }
                else {
                    // This is a mention id.
                    ConnectApi.MentionSegmentInput mentionSegmentInput = makeMentionSegmentInput(innerMatchedText);
                    messageSegmentInputs.add(mentionSegmentInput);
                    strPos = globalMatcher.end();
                }
            }
            else {
                // This is an HTML tag.
                boolean isBeginTag = !matchingText.startsWith('</');
                System.debug('isBeginTag > ' + isBeginTag);
                if (isBeginTag) {
                    // Strip off the < and >.
                    String tag = matchingText.substring(1, matchingText.indexOf('>'));
                    
                    System.debug('tag inside if > ' + tag);
                    if (supportedMarkup.containsKey(tag.toLowerCase())) {
                        
                        // Add a segment for any accumulated text (which includes unsupported HTML tags).
						addTextSegment(messageSegmentInputs, textSegment);
                        
                        ConnectApi.MarkupBeginSegmentInput markupBeginSegmentInput = makeMarkupBeginSegmentInput(tag);
                        System.debug('markupBeginSegmentInput > ' + markupBeginSegmentInput);
                        messageSegmentInputs.add(markupBeginSegmentInput);
                        strPos = globalMatcher.end();
                        
                    }else if(tag.contains('href') && supportedMarkup.containsKey('a')){
                        
                        System.debug('Found Anchor tag > ' + tag);
                        String linkSource = tag.substringBetween( 'href="', '"' ); 
                        System.debug('linkSource > ' + linkSource);
                        // Add a segment for any accumulated link (which includes unsupported HTML tags).
                        //makeMarkupBeginLinkSegmentInput(messageSegmentInputs, linkSource, '');
                        tag = 'a';
                        ConnectApi.MarkupBeginSegmentInput markupBeginSegmentInput = makeMarkupBeginLinkSegmentInput(tag, linkSource, '');
                        markupBeginSegmentInputUpdate = markupBeginSegmentInput;
                        System.debug('markupBeginSegmentInput > ' + markupBeginSegmentInput);
                        //messageSegmentInputs.add(markupBeginSegmentInput);
                        strPos = globalMatcher.end();
                        isTextFollowedByLink = true;
                    }
                    
                }
                else { // This is an end tag.
                    // Strip off the </ and >.
                    String tag = matchingText.substring(2, matchingText.indexOf('>'));
                    System.debug('tag inside else > ' + tag);
                    System.debug('isTextFollowedByLink > ' + isTextFollowedByLink);
                    if (supportedMarkup.containsKey(tag.toLowerCase()) || (tag.contains('href') && supportedMarkup.containsKey('a'))) {
                        if(isTextFollowedByLink && markupBeginSegmentInputUpdate <> null){
                            markupBeginSegmentInputUpdate.altText = textSegment;
                            System.debug('markupBeginSegmentInputUpdate > ' + markupBeginSegmentInputUpdate);
                            messageSegmentInputs.add(markupBeginSegmentInputUpdate);
                            isTextFollowedByLink = false;
                        }
                        // Add a segment for any accumulated text (which includes unsupported HTML tags).
                        addTextSegment(messageSegmentInputs, textSegment);
                        
                        ConnectApi.MarkupEndSegmentInput markupEndSegmentInput = makeMarkupEndSegmentInput(tag);
                        System.debug('markupEndSegmentInput > ' + markupEndSegmentInput);
                        messageSegmentInputs.add(markupEndSegmentInput);
                        strPos = globalMatcher.end();
                    }
                }
            }
        }
        
        // Take care of any text that comes after the last match.
        if (strPos < inputText.length()) {
            String trailingText = inputText.substring(strPos, inputText.length());
            System.debug('trailingText > ' + trailingText);
            addTextSegment(messageSegmentInputs, trailingText);
        }
        
        return messageSegmentInputs;
    }
    
    private static void addTextSegment(List<ConnectApi.MessageSegmentInput> messageSegmentInputs, String text) {
        if (text != null && text.length() > 0) {
            ConnectApi.TextSegmentInput textSegmentInput = makeTextSegmentInput(text);
            messageSegmentInputs.add(textSegmentInput);
        }
    }

    private static ConnectApi.TextSegmentInput makeTextSegmentInput(String text) {
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = text;
        return textSegment;
    }
    
    private static ConnectApi.MentionSegmentInput makeMentionSegmentInput(String mentionId) {
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = mentionId;
        return mentionSegment;
    }
    
    // Create entity link segment input using record ID
    // In the chatter post, it will display the Name of the record, with a hyperlink to view the record 
    private static ConnectApi.EntityLinkSegmentInput makeEntityLinkSegmentInput(String recordId) {
        ConnectApi.EntityLinkSegmentInput entityLinkSegment = new ConnectApi.EntityLinkSegmentInput();
        entityLinkSegment.entityId = recordId;
        return entityLinkSegment;
    }
    
    
    /**
* Create a MarkupBeginSegmentInput corresponding to the tag.  Checking whether the tag is
* supported markup should happen before calling this method.
*/
    private static ConnectApi.MarkupBeginSegmentInput makeMarkupBeginSegmentInput(String tag) {
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = supportedMarkup.get(tag.toLowerCase());
        return markupBeginSegment;
    }
    
    private static ConnectApi.MarkupBeginSegmentInput makeMarkupBeginLinkSegmentInput(String tag, String url, String altText) {
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = supportedMarkup.get(tag.toLowerCase());
        markupBeginSegment.url = url;
        markupBeginSegment.altText = altText;
        return markupBeginSegment;
    }
    
    /**
* Create a MarkupEndSegmentInput corresponding to the tag.  Checking whether the tag is
* supported markup should happen before calling this method.
*/
    private static ConnectApi.MarkupEndSegmentInput makeMarkupEndSegmentInput(String tag) {
        ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegment.markupType = supportedMarkup.get(tag.toLowerCase());
        return markupEndSegment;
    }
    
    private static ConnectApi.InlineImageSegmentInput makeInlineImageSegmentInput(String fileId, String altText) {
        ConnectApi.InlineImageSegmentInput inlineImageSegment = new ConnectApi.InlineImageSegmentInput();
        inlineImageSegment.fileId = fileId;
        if (String.isNotBlank(altText)) {
            inlineImageSegment.altText = altText;
        }
        return inlineImageSegment;
    }
    
}