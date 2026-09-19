<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('live_chat_messages', function (Blueprint $table) {
            $table->id();
            $table->string('name', 60);
            $table->string('message', 500);
            $table->date('day')->index();
            $table->string('ip', 45)->nullable();
            $table->boolean('hidden')->default(false);
            $table->unsignedInteger('reaction_count')->default(0);
            $table->timestamps();

            $table->index(['hidden', 'created_at']);
        });

        Schema::create('live_chat_reactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('live_chat_message_id')
                ->constrained('live_chat_messages')
                ->cascadeOnDelete();
            $table->string('emoji', 8);
            $table->string('ip', 45)->nullable();
            $table->timestamps();

            $table->index(['live_chat_message_id', 'emoji']);
            $table->unique(['live_chat_message_id', 'emoji', 'ip'], 'live_chat_react_uniq');
        });

        Schema::create('article_comments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('article_id')
                ->constrained('articles')
                ->cascadeOnDelete();
            $table->string('name', 60);
            $table->string('email', 200)->nullable();
            $table->text('body');
            $table->string('ip', 45)->nullable();
            $table->boolean('approved')->default(true);
            $table->timestamps();

            $table->index(['article_id', 'approved', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('article_comments');
        Schema::dropIfExists('live_chat_reactions');
        Schema::dropIfExists('live_chat_messages');
    }
};
