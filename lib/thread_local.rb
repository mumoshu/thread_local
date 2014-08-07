require "thread_local/version"

require 'set'

class ThreadLocal
  def initialize(initial_value, *args)
    opts, = args

    opts ||= {}

    @initial_value = to_callable(initial_value)
    @prefix = opts[:prefix] || 'thread_local'

    @threads_mutex = Mutex.new
    @threads = Set.new

    define_initializer!
  end

  def get
    t = Thread.current

    if set?
      t.thread_variable_get value_key
    else
      set @initial_value.call
    end
  end

  def set?
    t = Thread.current
    t.thread_variable_get value_initialized_key
  end

  def set(new_value)
    t = Thread.current

    t.thread_variable_set value_key, new_value
    t.thread_variable_set value_initialized_key, true

    forget_vanished_threads!

    @threads_mutex.synchronize do
      @threads.add(t.object_id)
    end

    new_value
  end

  def delete
    t = Thread.current

    t.thread_variable_set value_key, nil

    @threads_mutex.synchronize do
      @threads.delete(t.object_id)
    end
  end

  def __threads_object_ids__
    @threads
  end

  private

  # @return String
  def value_key
    "#{@prefix}_#{object_id}"
  end

  # @return String
  def value_initialized_key
    "#{@prefix}_#{object_id}_initialized"
  end

  # @param [Object] possibly_callable_object
  # @return Proc
  def to_callable(possibly_callable_object)
    if possibly_callable_object.respond_to? :call
      possibly_callable_object
    else
      -> { possibly_callable_object }
    end
  end

  def collect_threads_object_ids
    Thread.list.map(&:object_id)
  end

  def collect_threads_object_ids_as_set
    Set.new(collect_threads_object_ids)
  end

  def forget_vanished_threads!
    set = collect_threads_object_ids_as_set

    @threads_mutex.synchronize do |t|
      @threads.select do |threads_object_id|
        set.include? threads_object_id
      end
    end
  end

  def define_initializer!
    ObjectSpace.define_finalizer self do
      # We don't synchronize `@threads` here,
      # assuming that this finalizer won't be called concurrently with `ThreadLocal#set`
      @threads.each do |threads_object_id|
        t = Thread.all.find do |t|
          t.object_id == threads_object_id
        end

        unless t.nil?
          t.thread_variable_set key, nil
        end
      end
    end
  end
end
