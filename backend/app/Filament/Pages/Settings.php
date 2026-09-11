<?php

namespace App\Filament\Pages;

use App\Models\Setting;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Pages\Page;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;

class Settings extends Page
{
    protected string $view = 'filament.pages.settings';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::Cog6Tooth;

    protected static ?int $navigationSort = 90;

    public ?array $data = [];

    public function mount(): void
    {
        $this->form->fill(Setting::allAsMap());
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Live TV stream')
                    ->columns(2)
                    ->schema([
                        TextInput::make('tv_title')->label('TV title')->default('Gotabgaa TV'),
                        TextInput::make('tv_stream_url')
                            ->label('TV stream URL')
                            ->helperText('HLS (.m3u8), YouTube live embed, or any iframe URL.')
                            ->url()
                            ->columnSpanFull(),
                    ]),

                Section::make('Live radio stream')
                    ->columns(2)
                    ->schema([
                        TextInput::make('radio_title')->label('Radio title')->default('Gotabgaa Radio'),
                        TextInput::make('radio_frequency')->label('Frequency')->placeholder('102.5 FM'),
                        TextInput::make('radio_stream_url')
                            ->label('Radio stream URL')
                            ->helperText('Icecast / Shoutcast MP3 or AAC stream URL.')
                            ->url()
                            ->columnSpanFull(),
                    ]),

                Section::make('Social')
                    ->columns(2)
                    ->schema([
                        TextInput::make('social_facebook')->label('Facebook')->url(),
                        TextInput::make('social_twitter')->label('X (Twitter)')->url(),
                        TextInput::make('social_instagram')->label('Instagram')->url(),
                        TextInput::make('social_youtube')->label('YouTube')->url(),
                        TextInput::make('social_whatsapp')->label('WhatsApp channel')->url(),
                    ]),
            ])
            ->statePath('data');
    }

    protected function getFormActions(): array
    {
        return [
            Action::make('save')
                ->label('Save settings')
                ->submit('save'),
        ];
    }

    public function save(): void
    {
        $state = $this->form->getState();
        foreach ($state as $key => $value) {
            $group = str_starts_with($key, 'social_') ? 'social'
                : (str_contains($key, 'stream') || str_contains($key, 'title') || str_contains($key, 'frequency') ? 'stream' : 'general');
            Setting::set($key, $value, $group);
        }

        Notification::make()
            ->title('Settings saved')
            ->success()
            ->send();
    }
}
