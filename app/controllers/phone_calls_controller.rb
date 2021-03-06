class PhoneCallsController < ApplicationController
  TIME_LIMIT = 3600
  EARLY_OPEN = 300

  include Webhookable

  after_filter :set_header, except: :save_recording

  skip_before_action :verify_authenticity_token

  def jabberwocky
    response = Twilio::TwiML::Response.new do |r|
      r.Say verse, voice: 'alice', language: 'en-AU'
      r.Play 'http://linode.rabasa.com/cantina.mp3'
    end

    render_twiml response
  end

  def connect
    phone_call = validate_pin(params.require(:Digits).chomp('*'))

    response = Twilio::TwiML::Response.new do |rsp|
      if phone_call.present?
        rsp.Dial dial_options(phone_call) do
          rsp.Conference phone_call.pin, conference_options(phone_call)
        end
      else
        rsp.Say 'Sorry, the pin you entered was not recognized. Please call back to try again.',
          voice: 'alice'
      end
    end

    render_twiml response
  end

  def fetch_pin
    response = Twilio::TwiML::Response.new do |rsp|
      rsp.Gather fetch_pin_options do
        rsp.Say 'Please enter your 8-digit pin and then press star.', voice: 'alice'
      end
      rsp.Gather fetch_pin_options do
        rsp.Say 'Sorry, I didn\'t catch that. Please enter your 8-digit pin and then press star.', voice: 'alice'
      end
      rsp.Say 'No response detected. Please call back to try again.', voice: 'alice'
    end

    render_twiml response
  end

  def fallback
    response = Twilio::TwiML::Response.new do |rsp|
      rsp.Say 'Sorry, the call system is currently unavailable. Please try again in a few minutes.',
        voice: 'alice'
    end

    render_twiml response
  end

  def save_outcome
    phone_call = PhoneCall.find(params[:id])
    phone_call.update(outcome: params.require(:DialCallStatus), status: :completed)

    response = Twilio::TwiML::Response.new do |rsp|
      rsp.Say 'Goodbye!', voice: 'alice'
    end

    render_twiml response
  end

  def save_recording
    phone_call = PhoneCall.find(params[:id])
    phone_call.update(recording_url: params.require(:RecordingUrl))
    render json: {}, status: :ok
  end

  private

  def fetch_pin_options
    {
      numDigits: 8,
      finishOnKey: '*',
      timeout: 15 ,
      action: '/phone_calls/connect'
    }
  end

  def dial_options(phone_call)
    {
      timeLimit: TIME_LIMIT,
      action: save_outcome_phone_call_path(phone_call)
    }
  end

  def conference_options(phone_call)
    {
      waitUrl: 'http://twimlets.com/holdmusic?Bucket=com.twilio.music.guitars',
      record: 'record-from-start',
      eventCallbackUrl: save_recording_phone_call_path(phone_call)
    }
  end

  def validate_pin(pin)
    phone_call = PhoneCall.find_by(pin: pin)
    return nil unless in_call_window?(phone_call)
    phone_call
  end

  def in_call_window?(phone_call)
    return false unless phone_call.status == 'scheduled'
    call_time = phone_call.scheduled_time
    Time.current.between?(call_time - EARLY_OPEN.seconds, call_time + TIME_LIMIT.seconds)
  end

  def verse
    'Twas brillig, and the slithy toves
    Did gyre and gimble in the wabe:
    All mimsy were the borogoves,
    And the mome raths outgrabe.
    "Beware the Jabberwock, my son!
    The jaws that bite, the claws that catch!
    Beware the Jubjub bird, and shun
    The frumious Bandersnatch!"
    He took his vorpal sword in hand:
    Long time the manxome foe he sought --
    So rested he by the Tumtum tree,
    And stood awhile in thought.
    And, as in uffish thought he stood,
    The Jabberwock, with eyes of flame,
    Came whiffling through the tulgey wood,
    And burbled as it came!
    One, two! One, two! And through and through
    The vorpal blade went snicker-snack!
    He left it dead, and with its head
    He went galumphing back.
    "And, has thou slain the Jabberwock?
    Come to my arms, my beamish boy!
    O frabjous day! Callooh! Callay!
    He chortled in his joy.'.gsub(/\s{2,}/, ' ')
  end
end
