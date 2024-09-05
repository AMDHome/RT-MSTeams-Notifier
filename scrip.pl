use LWP::UserAgent;
use HTTP::Request;
use JSON;

my $ua = LWP::UserAgent->new;
my $webhook_url = 'https://YOUR_WEBHOOK_URL';
my $rt_domain = 'https://example.com/rt'

# Get Information on the ticket
my $ticket_id = $self->TicketObj->Id;
my $ticket_subject = $self->TicketObj->Subject;
my $transaction_content = $self->TransactionObj->Content;

# Get the requestor(s)
my $requestors = $self->TicketObj->Requestor->UserMembersObj;
my @requestor_array;
while (my $requestor = $requestors->Next) {
    my $requestor_name = $requestor->RealName || $requestor->Name;
    my $requestor_email = $requestor->EmailAddress;
    push @requestor_array, "$requestor_name &lt;$requestor_email&gt;";
}

my $requestor_list = join(', ', @requestor_array);

# Define the JSON data
my $json_data = {
    type => "message",
    summary => "New Ticket: [$ticket_id] $ticket_subject",
    attachments => [
        {
            contentType => "application/vnd.microsoft.card.adaptive",
            contentUrl => undef,
            content => {
                '$schema' => "http://adaptivecards.io/schemas/adaptive-card.json",
                type => "AdaptiveCard",
                version => "1.2",
                body => [
                    {
                        type => "TextBlock",
                        text => "**New Ticket**",
                        size => "Small",
                        horizontalAlignment => "Left",
                        spacing => "None",
                    },
                    {
                        type => "TextBlock",
                        text => "[**[$ticket_id]** $ticket_subject]($rt_domain/Ticket/Display.html?id=$ticket_id)",
                        size => "Large",
                        color => "Accent",
                        spacing => "Small",
                        width => "stretch",
                        wrap => "true",
                    },
                    {
                        type => "TextBlock",
                        text => "**Requestors:** $requestor_list",
                        spacing => "Small",
                        width => "stretch",
                        wrap => "true",
                    },
                ],
                actions =>
                [
                    {
                        type => "Action.OpenUrl",
                        title => "View in RT",
                        url => "$rt_domain/Ticket/Display.html?id=$ticket_id"
                    },
                    {
                        type => "Action.ShowCard",
                        title => "Show Content",
                        card =>
                        {
                            type => "AdaptiveCard",
                            body =>
                            [
                                {
                                    type => "TextBlock",
                                    wrap => "true",
                                    text => "$transaction_content",
                                }
                            ],
                            '$schema' => "http://adaptivecards.io/schemas/adaptive-card.json"
                        }
                    },
                ],
                msteams =>
                {
                    width => "Full"
                }
            }
        }
    ]
};

# Convert the Perl hash reference to a JSON list
my $json_text = encode_json($json_data);

# set custom HTTP request header fields
my $req = HTTP::Request->new(POST => $webhook_url);
$req->header('content-type' => 'application/json');
$req->content($json_text);

# Send Request
my $resp = $ua->request($req);

# Deal with any response
if ($resp->is_success) {
    my $message = $resp->decoded_content;
    RT::Logger->debug("Received reply: $message\n");
} else {
    RT::Logger->error("HTTP GET error code: ", $resp->code, "\n");
    RT::Logger->error("HTTP GET error message: ", $resp->message, "\n");
    return 0;
}

return 1;
