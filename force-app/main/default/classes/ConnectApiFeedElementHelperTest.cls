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
 * Unit tests for ConnectApiHelper.
 *
 * This class works with API version 43.0 and later. There are separate classes
 * that work with v42.0 and earlier.
 *
 * See https://github.com/forcedotcom/ConnectApiHelper for more information.
 *
 */

@IsTest(SeeAllData=true)
public class ConnectApiFeedElementHelperTest {

    @IsTest(SeeAllData=true)
    static void testRichTextInput() {
        String userId = UserInfo.getUserId();
        String body = '<p><b>bold </b><i>italic</i></p><p><u>undeline</u></p><p><strike>strike</strike></p><p><br></p><p>bullet list</p><ul><li>item 1</li><li>item 2</li><li>item 3</li></ul><p>number list </p><ol><li>item 1</li><li>item 2</li><li>item 3</li></ol><p><a href="https://" rel="noopener noreferrer" target="_blank">link </a></p><p><br></p><p><img src="/informaticaNetwork/servlet/rtaImage?refid=0EM7j000000HG5l"></p>';
    	ConnectApiFeedElementHelper.getMessageSegmentInputs(body);
        
        //{record:'+userId+'} {img: 0EM7j000000HG5l}
    }
    
    @IsTest(SeeAllData=true)
    static void testRichTextInputRecordId() {
        String userId = UserInfo.getUserId();
        String body = '{record:01t3E000002GCm9QAG}';
        ConnectApiFeedElementHelper.getMessageSegmentInputs(body);
        
    }
    
    @IsTest(SeeAllData=true)
    static void testRichTextInputImg() {
        String userId = UserInfo.getUserId();
        String body = '{img:069x00000000D7m:View of the Space Needle from our office.}';
        ConnectApiFeedElementHelper.getMessageSegmentInputs(body);
        
    }
    @IsTest(SeeAllData=true)
    static void testRichTextInputMention() {
        String userId = UserInfo.getUserId();
        String body = '{mention:01t3E000002GCm9QAG}';
        ConnectApiFeedElementHelper.getMessageSegmentInputs(body);
        
    }
    
    @IsTest(SeeAllData=true)
    static void testLinkAndHashtagParsing() {
        // The test string is: #Yolo: http://salesforce.com, {005} {005x0000000URNPzzz} test.
        //                     [   ][][                   ][      ][                  ][    ]
        //                     0    1 2                    3       4                   5
        // 0 = hashtag
        // 1 = text1
        // 2 = link
        // 3 = text2
        // 4 = mention
        // 5 = text3

        String hashtag = 'Yolo';
        String text1 = ': ';
        String link = 'http://salesforce.com';
        String text2 = ', {005} ';
        String mentionId = UserInfo.getUserId();
        String text3 = ' test.';
        String text = '#' + hashtag + text1 + link + text2 + '{' + mentionId + '}' + text3;

        ConnectApi.FeedElement fi = ConnectApiFeedElementHelper.postFeedItemWithRichText(null, 'me', text);

        List<ConnectApi.MessageSegment> segments = fi.body.messageSegments;

        System.assertEquals(6, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.HashtagSegment);
        System.assert(segments.get(1) instanceof ConnectApi.TextSegment);
        System.assert(segments.get(2) instanceof ConnectApi.LinkSegment);
        System.assert(segments.get(3) instanceof ConnectApi.TextSegment);
        System.assert(segments.get(4) instanceof ConnectApi.MentionSegment);
        System.assert(segments.get(5) instanceof ConnectApi.TextSegment);

        ConnectApi.HashtagSegment hashtagSegment = (ConnectApi.HashtagSegment) segments.get(0);
        System.assertEquals(hashtag, hashtagSegment.tag);

        ConnectApi.TextSegment textSegment1 = (ConnectApi.TextSegment) segments.get(1);
        System.assertEquals(text1, textSegment1.text);

        ConnectApi.LinkSegment linkSegment = (ConnectApi.LinkSegment) segments.get(2);
        System.assertEquals(link, linkSegment.url);

        ConnectApi.TextSegment textSegment2 = (ConnectApi.TextSegment) segments.get(3);
        System.assertEquals(text2, textSegment2.text);

        ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segments.get(4);
        System.assertEquals(mentionId, mentionSegment.record.id);

        ConnectApi.TextSegment textSegment3 = (ConnectApi.TextSegment) segments.get(5);
        System.assertEquals(text3, textSegment3.text);
    }

    @IsTest(SeeAllData=true)
    static void testCreateInputFromBody() {

        // We'll post a feed item that contains text, link, hashtag, mention, and markup segments,
        // and then call the helper method on the resulting body.

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        // We can put the link and hashtag parts into a text segment to post the feed item. When it gets retrieved, it will have
        // separate segments for the text, link and hashtag.
        String expectedText = 'Text ';
        String expectedLink = 'http://link.com';
        String expectedHashtag = 'hashtag';
        String expectedBoldText = 'Bold text';

        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = expectedText + expectedLink + ' #' + expectedHashtag;
        messageBodyInput.messageSegments.add(textSegmentInput);

        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = UserInfo.getUserId();
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        ConnectApi.MarkupBeginSegmentInput markupBeginSegmentInput = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegmentInput.markupType = ConnectApi.MarkupType.Bold;
        messageBodyInput.messageSegments.add(markupBeginSegmentInput);

        textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = expectedBoldText;
        messageBodyInput.messageSegments.add(textSegmentInput);

        ConnectApi.MarkupEndSegmentInput markupEndSegmentInput = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegmentInput.markupType = ConnectApi.MarkupType.Bold;
        messageBodyInput.messageSegments.add(markupEndSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = UserInfo.getUserId();

        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);

        ConnectApi.MessageBodyInput input = ConnectApiHelper.createInputFromBody(feedElement.body);
        System.assertEquals(8, input.messageSegments.size(), 'Wrong number of message segments.');

        System.assert(input.messageSegments.get(0) instanceof ConnectApi.TextSegmentInput, 'Segment 0 is not a text segment input.');
        ConnectApi.TextSegmentInput textInput = (ConnectApi.TextSegmentInput) input.messageSegments.get(0);
        System.assertEquals(expectedText, textInput.text, 'Segment 0 text does not match.');

        System.assert(input.messageSegments.get(1) instanceof ConnectApi.LinkSegmentInput, 'Segment 1 is not a link segment input.');
        ConnectApi.LinkSegmentInput linkInput = (ConnectApi.LinkSegmentInput) input.messageSegments.get(1);
        System.assertEquals(expectedLink, linkInput.url, 'Segment 1 url does not match.');

        System.assert(input.messageSegments.get(2) instanceof ConnectApi.TextSegmentInput, 'Segment 2 is not a text segment input.');
        ConnectApi.TextSegmentInput textInput2 = (ConnectApi.TextSegmentInput) input.messageSegments.get(2);
        System.assertEquals(' ', textInput2.text, 'Segment 2 text does not match.');

        System.assert(input.messageSegments.get(3) instanceof ConnectApi.HashtagSegmentInput, 'Segment 3 is not a hashtag segment input.');
        ConnectApi.HashtagSegmentInput hashtagInput = (ConnectApi.HashtagSegmentInput) input.messageSegments.get(3);
        System.assertEquals(expectedHashtag, hashtagInput.tag, 'Segment 3 hashtag does not match.');

        System.assert(input.messageSegments.get(4) instanceof ConnectApi.MentionSegmentInput, 'Segment 4 is not a mention segment input.');
        ConnectApi.MentionSegmentInput mentionInput = (ConnectApi.MentionSegmentInput) input.messageSegments.get(4);
        System.assertEquals(UserInfo.getUserId(), mentionInput.id, 'Segment 4 mention ID does not match.');

        System.assert(input.messageSegments.get(5) instanceof ConnectApi.MarkupBeginSegmentInput, 'Segment 5 is not a markup begin segment input.');
        ConnectApi.MarkupBeginSegmentInput markupBeginInput = (ConnectApi.MarkupBeginSegmentInput) input.messageSegments.get(5);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupBeginInput.markupType, 'Segment 5 markup type does not match.');

        System.assert(input.messageSegments.get(6) instanceof ConnectApi.TextSegmentInput, 'Segment 6 is not a text segment input.');
        ConnectApi.TextSegmentInput textInput3 = (ConnectApi.TextSegmentInput) input.messageSegments.get(6);
        System.assertEquals(expectedBoldText, textInput3.text, 'Segment 6 text does not match.');

        System.assert(input.messageSegments.get(7) instanceof ConnectApi.MarkupEndSegmentInput, 'Segment 7 is not a markup end segment input.');
        ConnectApi.MarkupEndSegmentInput markupEndInput = (ConnectApi.MarkupEndSegmentInput) input.messageSegments.get(7);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupEndInput.markupType, 'Segment 7 markup type does not match.');

        // Get coverage for the createFeedItemInputFromBody() method.
        ConnectApi.FeedItemInput feedItemInput2 = ConnectApiHelper.createFeedItemInputFromBody(feedElement.body);
        System.assertEquals(input, feedItemInput2.body, 'createFeedItemInputFromBody is returning a different input body than createInputFromBody.');

        // Get coverage for the createCommentInputFromBody() method.
        ConnectApi.CommentInput commentInput = ConnectApiHelper.createCommentInputFromBody(feedElement.body);
        System.assertEquals(input, commentInput.body, 'createCommentInputFromBody is returning a different input body than createInputFromBody.');
    }

    @IsTest(SeeAllData=true)
    static void testCreateInputFromBodyWithGeneratedSegment() {
        ConnectApi.FeedBody body = new ConnectApi.FeedBody();
        body.messageSegments = new List<ConnectApi.MessageSegment>();

        // Mock up an entity link segment.
        ConnectApi.EntityLinkSegment entityLinkSegment = new ConnectApi.EntityLinkSegment();
        entityLinkSegment.text = 'blah';

        body.messageSegments.add(entityLinkSegment);
        body.text = 'blah';

        ConnectApi.MessageBodyInput input = ConnectApiHelper.createInputFromBody(body);
        System.assertEquals(0, input.messageSegments.size(), 'Wrong number of message segments.');
    }

    @IsTest(SeeAllData=true)
    static void testCreateInputFromBodyWithNewLine() {
        // In order for newlines to display properly in rich text, they need to be turned into
        // paragraph markup segments.
        ConnectApi.FeedBody body = new ConnectApi.FeedBody();
        body.messageSegments = new List<ConnectApi.MessageSegment>();

        // Mock up an text segment containing a newline character.
        ConnectApi.TextSegment textSegment = new ConnectApi.TextSegment();
        String newline = EncodingUtil.urlDecode('%0A', 'UTF-8'); 
        textSegment.text = 'foo' + newline + 'bar';

        body.messageSegments.add(textSegment);
        body.text = textSegment.text;

        ConnectApi.MessageBodyInput input = ConnectApiHelper.createInputFromBody(body);
        // We expect 4 segments:
        // 1. TextSegmentInput 'foo'
        // 2. MarkupBeginSegmentInput for <p>
        // 3. MarkupEndSegmentInput for <p>
        // 4. TextSegmentInput 'bar'
    }

    @IsTest(SeeAllData=true)
    static void testCreateInputFromBodyWithTwoNewLines() {
        // In order for newlines to display properly in rich text, they need to be turned into
        // paragraph markup segments.
        
        ConnectApi.FeedBody body = new ConnectApi.FeedBody();
        body.messageSegments = new List<ConnectApi.MessageSegment>();

        // Mock up an text segment containing a newline character.
        ConnectApi.TextSegment textSegment = new ConnectApi.TextSegment();
        String newline = EncodingUtil.urlDecode('%0A', 'UTF-8'); 
        textSegment.text = 'foo' + newline + newline + 'bar';

        body.messageSegments.add(textSegment);
        body.text = textSegment.text;

        ConnectApi.MessageBodyInput input = ConnectApiHelper.createInputFromBody(body);
        // We expect 5 segments:
        // 1. TextSegmentInput 'foo'
        // 2. MarkupBeginSegmentInput for <p>
        // 3. TextSegmentInput '&nbsp;'
        // 4. MarkupEndSegmentInput for <p>
        // 5. TextSegmentInput 'bar'
        //System.assertEquals(5, input.messageSegments.size(), 'Wrong number of message segments.');
        System.assert(input.messageSegments[0] instanceof ConnectApi.TextSegmentInput, 'Wrong type for input 0'); 
    }
    
    @IsTest(SeeAllData=true)
    static void testUnsupportedMarkup() {
        // <span>a</span>, <h1><a>b</a> <br> <b>Does this work?</b></h1>
        // [0                               ][1][2            ][3 ][4  ]
        // 0 = text1
        // 1 = markup begin
        // 2 = text2
        // 3 = markup end
        // 4 = text3
        String text1 = '<span>a</span>, <h1><a>b</a> <br> ';
        String text2 = 'Does this work?';
        String text3 = '</h1>';
        String text = text1 + '<b>' + text2 + '</b>' + text3;

        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(text);

        System.assertEquals(5, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(1) instanceof ConnectApi.MarkupBeginSegmentInput);
        System.assert(segments.get(2) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(3) instanceof ConnectApi.MarkupEndSegmentInput);
        System.assert(segments.get(4) instanceof ConnectApi.TextSegmentInput);

        ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(0);
        System.assertEquals(text1, textSegment.text);

        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(1);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupBeginSegment.markupType);

        textSegment = (ConnectApi.TextSegmentInput) segments.get(2);
        System.assertEquals(text2, textSegment.text);

        ConnectApi.MarkupEndSegmentInput markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(3);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupEndSegment.markupType);

        textSegment = (ConnectApi.TextSegmentInput) segments.get(4);
        System.assertEquals(text3, textSegment.text);
    }

    @IsTest(SeeAllData=true)
    static void testSimpleMarkup() {
        String restOfMessage = 'blah';
        String text = '<u>' + restOfMessage + '</u>';
        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(text);

        System.assertEquals(3, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.MarkupBeginSegmentInput);
        System.assert(segments.get(1) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(2) instanceof ConnectApi.MarkupEndSegmentInput);

        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(0);
        System.assertEquals(ConnectApi.MarkupType.Underline, markupBeginSegment.markupType);

        ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(1);
        System.assertEquals(restOfMessage, textSegment.text);

        ConnectApi.MarkupEndSegmentInput markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(2);
        System.assertEquals(ConnectApi.MarkupType.Underline, markupEndSegment.markupType);
    }

    @IsTest(SeeAllData=true)
    static void testMarkupCasing() {
        String text1 = 'foo';
        String text2 = 'bar';
        String text3 = 'baz';
        String text = '<U>' + text1 + '</U><b>' + text2 + '</B><oL><li>' + text3 + '</li></oL>';
        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(text);

        System.assertEquals(11, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.MarkupBeginSegmentInput);
        System.assert(segments.get(1) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(2) instanceof ConnectApi.MarkupEndSegmentInput);
        System.assert(segments.get(3) instanceof ConnectApi.MarkupBeginSegmentInput);
        System.assert(segments.get(4) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(5) instanceof ConnectApi.MarkupEndSegmentInput);
        System.assert(segments.get(6) instanceof ConnectApi.MarkupBeginSegmentInput);
        System.assert(segments.get(7) instanceof ConnectApi.MarkupBeginSegmentInput);
        System.assert(segments.get(8) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(9) instanceof ConnectApi.MarkupEndSegmentInput);
        System.assert(segments.get(10) instanceof ConnectApi.MarkupEndSegmentInput);

        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(0);
        System.assertEquals(ConnectApi.MarkupType.Underline, markupBeginSegment.markupType);

        ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(1);
        System.assertEquals(text1, textSegment.text);

        ConnectApi.MarkupEndSegmentInput markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(2);
        System.assertEquals(ConnectApi.MarkupType.Underline, markupEndSegment.markupType);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(3);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupBeginSegment.markupType);

        textSegment = (ConnectApi.TextSegmentInput) segments.get(4);
        System.assertEquals(text2, textSegment.text);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(5);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupEndSegment.markupType);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(6);
        System.assertEquals(ConnectApi.MarkupType.OrderedList, markupBeginSegment.markupType);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(7);
        System.assertEquals(ConnectApi.MarkupType.ListItem, markupBeginSegment.markupType);

        textSegment = (ConnectApi.TextSegmentInput) segments.get(8);
        System.assertEquals(text3, textSegment.text);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(9);
        System.assertEquals(ConnectApi.MarkupType.ListItem, markupEndSegment.markupType);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(10);
        System.assertEquals(ConnectApi.MarkupType.OrderedList, markupEndSegment.markupType);
    }

    @IsTest(SeeAllData=true)
    static void testInlineImage() {
        String restOfMessage = 'Check out this image!';
        String imageId = '069B0000000q7hi';
        String altText = 'Some alt text.';
        String text = restOfMessage + '{img:' + imageId + ':' + altText + '}';
        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(text);

        System.assertEquals(2, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(1) instanceof ConnectApi.InlineImageSegmentInput);

        ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(0);
        System.assertEquals(restOfMessage, textSegment.text);

        ConnectApi.InlineImageSegmentInput inlineImageSegment = (ConnectApi.InlineImageSegmentInput) segments.get(1);
        System.assertEquals(imageId, inlineImageSegment.fileId);
        System.assertEquals(altText, inlineImageSegment.altText);
    }

    @IsTest(SeeAllData=true)
    static void testInlineImageNoAltText() {
        String imageId = '069B0000000q7hi';
        String text = '{img:' + imageId + '}';
        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(text);

        System.assertEquals(1, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.InlineImageSegmentInput);

        ConnectApi.InlineImageSegmentInput inlineImageSegment = (ConnectApi.InlineImageSegmentInput) segments.get(0);
        System.assertEquals(imageId, inlineImageSegment.fileId);
        System.assertEquals(null, inlineImageSegment.altText);
    }

    @IsTest(SeeAllData=true)
    static void testInlineImageAltTextSyntax() {
        String imageId15 = '069B0000000q7hi';
        String imageId18 = '069B0000000q7hixxx';
        String altText1 = 'Alt text with a colon : in the middle.';
        String badSyntax1 = 'Alt text with a closing brace ';
        String badSyntax2 = ' in the middle.}';
        String badSyntaxAltText = badSyntax1 + '}' + badSyntax2;
        String text = '{img:' + imageId15 + ':' + altText1 + '}{img:' + imageId18 + ':}{img:' + imageId15 + ':' + badSyntaxAltText;
        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(text);

        System.assertEquals(4, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.InlineImageSegmentInput);
        System.assert(segments.get(1) instanceof ConnectApi.InlineImageSegmentInput);
        System.assert(segments.get(2) instanceof ConnectApi.InlineImageSegmentInput);
        System.assert(segments.get(3) instanceof ConnectApi.TextSegmentInput);

        ConnectApi.InlineImageSegmentInput inlineImageSegment = (ConnectApi.InlineImageSegmentInput) segments.get(0);
        System.assertEquals(imageId15, inlineImageSegment.fileId);
        System.assertEquals(altText1, inlineImageSegment.altText);

        inlineImageSegment = (ConnectApi.InlineImageSegmentInput) segments.get(1);
        System.assertEquals(imageId18, inlineImageSegment.fileId);
        System.assertEquals(null, inlineImageSegment.altText);

        inlineImageSegment = (ConnectApi.InlineImageSegmentInput) segments.get(2);
        System.assertEquals(imageId15, inlineImageSegment.fileId);
        System.assertEquals(badSyntax1, inlineImageSegment.altText);

        ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(3);
        System.assertEquals(badSyntax2, textSegment.text);
    }


    @IsTest(SeeAllData=true)
    static void testMarkupAndMention() {
        String mentionId = '005x0000000URNPzzz';
        String message = 'How are you';
        String questionMark = '?';
        String text = '<b>' + message + '<i>{' + mentionId + '}</i>' + questionMark + '</b>';
        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(text);

        System.assertEquals(7, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.MarkupBeginSegmentInput);
        System.assert(segments.get(1) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(2) instanceof ConnectApi.MarkupBeginSegmentInput);
        System.assert(segments.get(3) instanceof ConnectApi.MentionSegmentInput);
        System.assert(segments.get(4) instanceof ConnectApi.MarkupEndSegmentInput);
        System.assert(segments.get(5) instanceof ConnectApi.TextSegmentInput);
        System.assert(segments.get(6) instanceof ConnectApi.MarkupEndSegmentInput);

        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(0);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupBeginSegment.markupType);

        ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(1);
        System.assertEquals(message, textSegment.text);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(2);
        System.assertEquals(ConnectApi.MarkupType.Italic, markupBeginSegment.markupType);

        ConnectApi.MentionSegmentInput mentionSegment = (ConnectApi.MentionSegmentInput) segments.get(3);
        System.assertEquals(mentionId, mentionSegment.id);

        ConnectApi.MarkupEndSegmentInput markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(4);
        System.assertEquals(ConnectApi.MarkupType.Italic, markupEndSegment.markupType);

        textSegment = (ConnectApi.TextSegmentInput) segments.get(5);
        System.assertEquals(questionMark, textSegment.text);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(6);
        System.assertEquals(ConnectApi.MarkupType.Bold, markupEndSegment.markupType);
    }

    @IsTest(SeeAllData=true)
    static void testAllMarkupAndInlineImage() {
        // <p><i>This is an italicized paragraph.</i></p>
        // <ul><li><s>A completed item in an unordered list.</s></li></ul>
        // <ol><li><u>An underlined item in an ordered list.</u></li></ol>
        // <b>And, of course, an image for you:</b> {img:069B0000000q7hi:An image of something nice.}
        // <code>int foo = 1 / 0;</code>
        String text1 = 'This is an italicized paragraph.';
        String text2 = 'A completed item in an unordered list.';
        String text3 = 'An underlined item in an ordered list.';
        String text4 = 'And, of course, an image for you: ';
        String text5 = ' ';
        String imageId = '069B0000000q7hi';
        String altText = 'An image of something nice.';
        String code = 'int foo = 1 / 0;';
        String text = '<p><i>' + text1 + '</i></p><ul><li><s>' + text2 + '</s></li></ul><ol><li><u>'
                        + text3 + '</u></li></ol><b>' + text4 + '</b> {img:' + imageId + ':' + altText + '}'
                        + '<code>' + code + '</code>';
        List<ConnectApi.MessageSegmentInput> segments = ConnectApiHelper.getMessageSegmentInputs(text);

        // <p><i>This is an italicized paragraph.</i></p>
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(0);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(1);

        ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(2);

        ConnectApi.MarkupEndSegmentInput markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(3);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(4);

        // <ul><li><s>A completed item in an unordered list.</s></li></ul>
        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(5);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(6);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(7);

        textSegment = (ConnectApi.TextSegmentInput) segments.get(8);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(9);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(10);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(11);

        // <ol><li><u>An underlined item in an ordered list.</u></li></ol>
        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(12);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(13);

        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(14);

        textSegment = (ConnectApi.TextSegmentInput) segments.get(15);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(16);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(17);

        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(18);

        // <b>And, of course, an image for you:</b> {img:069B0000000q7hi:An image of something nice.}
        markupBeginSegment = (ConnectApi.MarkupBeginSegmentInput) segments.get(19);
        
        textSegment = (ConnectApi.TextSegmentInput) segments.get(20);
        
        markupEndSegment = (ConnectApi.MarkupEndSegmentInput) segments.get(21);

        textSegment = (ConnectApi.TextSegmentInput) segments.get(22);

        ConnectApi.InlineImageSegmentInput inlineImageSegment = (ConnectApi.InlineImageSegmentInput) segments.get(23);
      

    }
}