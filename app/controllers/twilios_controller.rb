class TwiliosController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def jabberwocky
    response_object do |r|
      r.Say verse, voice: 'alice', language: 'en-AU'
      r.Play 'http://linode.rabasa.com/cantina.mp3'
    end

    render_twiml response
  end

  def beethoven
    response_object do |r|
      r.Say 'Hören Sie sich einige verdammt Beethoven', voice: 'alice', language: 'de-DE'
      r.Play random_beethoven_url
    end

    render_twiml response
  end

  private

  def response_object
    @response_object ||= Twilio.TwiML::Response.new
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

  def random_beethoven_url
    %w(
      http://www.amclassical.com/mp3/amclassical_beethoven_fur_elise.mp3
      http://www.amclassical.com/mp3/amclassical_moonlight_sonata_movement_1.mp3
      http://www.amclassical.com/mp3/amclassical_moonlight_sonata_movement_2.mp3
      http://www.amclassical.com/mp3/amclassical_pathetique_sonata_movement_2.mp3
    )
  end
end
